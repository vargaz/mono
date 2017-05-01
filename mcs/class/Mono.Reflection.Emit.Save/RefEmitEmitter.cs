using System;
using System.Collections.Generic;
using System.Reflection;
using System.Reflection.Emit;
using System.Runtime.InteropServices;
using System.Security;
using System.Security.Permissions;
using Mono.Cecil;
using Mono.Cecil.Cil;

// UnmanagedMarshal
#pragma warning disable CS0618

public class RefEmitEmitter
{
	public static void EmitAssembly (AssemblyBuilder ab, string assemblyFileName, AssemblyName ab_name) {
		new RefEmitEmitter ().Emit (ab, assemblyFileName, ab_name);
	}

	public void Emit (AssemblyBuilder ab, string assemblyFileName, AssemblyName ab_name) {
		var aname = MapAssemblyName (ab_name);

		var sre_modules = ab.GetModulesInternal ();

		/*
		if (sre_modules.Length != 1)
			throw new NotImplementedException ();
		*/

		var moduleb = sre_modules [0];

		var ad = AssemblyDefinition.CreateAssembly (aname, moduleb.Name, ModuleKind.Dll);

		foreach (var mb in sre_modules) {
			ModuleDefinition md;
			if (mb == moduleb)
				md = ad.MainModule;
			else
				md = ModuleDefinition.CreateModule (mb.Name, ModuleKind.Dll);

			var mapper = new ModuleMapper (ab, ad, (ModuleBuilder)mb, md);
			mapper.Map ();
		}
		
		ad.Write (assemblyFileName); // + ".2");
	}

	AssemblyNameDefinition MapAssemblyName (AssemblyName name) {
		// FIXME: public key/token
		var aname = new AssemblyNameDefinition (name.Name, name.Version);
		if (name.CultureInfo != null)
			aname.Culture = name.CultureInfo.Name;
		aname.Attributes = (AssemblyAttributes)name.Flags;
		aname.HashAlgorithm = (AssemblyHashAlgorithm)(uint)name.HashAlgorithm;
		return aname;
	}
}

internal class ModuleMapper
{
	AssemblyBuilder assemblyb;
	AssemblyDefinition ad;
	ModuleBuilder moduleb;
	ModuleDefinition md;
	TypeBuilder global_type;
	Dictionary<Type, TypeDefinition> type_map;
	Dictionary<MethodInfo, MethodDefinition> method_map;
	Dictionary<Assembly, AssemblyNameReference> assembly_map;

	public ModuleMapper (AssemblyBuilder assemblyb, AssemblyDefinition ad, ModuleBuilder moduleb, ModuleDefinition md) {
		this.assemblyb = assemblyb;
		this.ad = ad;
		this.moduleb = moduleb;
		this.md = md;
		type_map = new Dictionary<Type, TypeDefinition> ();
		method_map = new Dictionary<MethodInfo, MethodDefinition> ();
		assembly_map = new Dictionary<Assembly, AssemblyNameReference> ();
	}

	public void Map () {
		md.Mvid = moduleb.GetModuleVersionId ();

		global_type = moduleb.GetGlobalTypeInternal ();
		if (global_type != null) {
			global_type.CreateType ();
			type_map [global_type] = md.Types [0];
			type_map [global_type.CreateType ()] = md.Types [0];
		}
		Type[] tbs = moduleb.GetTypeBuilders ();
		foreach (TypeBuilder tb in tbs) {
			if (tb == null)
				continue;
			if (tb == global_type)
				continue;
			CreateTypeDefFor (tb);
		}

		if (md == ad.MainModule) {
			foreach (var cattrb in assemblyb.GetCustomAttributeBuilders ())
				ad.CustomAttributes.Add (MapCattr (cattrb));
		}

		foreach (var cattrb in moduleb.GetCustomAttributeBuilders ())
			md.CustomAttributes.Add (MapCattr (cattrb));

		if (global_type != null)
			MapTypeBuilder (global_type);
		foreach (TypeBuilder tb in tbs) {
			if (tb == null)
				continue;
			if (tb == global_type)
				continue;
			MapTypeBuilder (tb);
		}
	}

	CustomAttribute MapCattr (CustomAttributeBuilder cattrb) {
		return new CustomAttribute (MapMethod (cattrb.Ctor), cattrb.Data);
	}

	void CreateTypeDefFor (TypeBuilder tb) {
		tb.CreateType ();

		var td = new TypeDefinition (tb.Namespace, tb.Name, (Mono.Cecil.TypeAttributes)tb.Attributes);
		type_map [tb] = td;
		type_map [tb.CreateType ()] = td;

		foreach (var mb in tb.GetMethodBuilders ()) {
			if (mb == null)
				continue;
			var rtype = AddModifiers (MapType (mb.ReturnType), mb.GetReturnModReq (), mb.GetReturnModOpt ());
			var md = new MethodDefinition (mb.Name, (Mono.Cecil.MethodAttributes)mb.Attributes, rtype);
			method_map [mb] = md;
		}

		foreach (TypeBuilder nested_tb in tb.GetNestedTypes (BindingFlags.Public|BindingFlags.NonPublic))
			CreateTypeDefFor (nested_tb);
	}

	IMetadataScope MapAssemblyRef (Assembly assembly) {
		AssemblyNameReference aref = null;

		if (assembly == typeof (object).Assembly)
			return md.TypeSystem.CoreLibrary;

		if (!assembly_map.TryGetValue (assembly, out aref)) {
			var parent_aname = assembly.GetName (false);

			aref = AssemblyNameReference.Parse (parent_aname.FullName);
			md.AssemblyReferences.Add (aref);
			// FIXME: This shouldn't be global
			assembly_map [assembly] = aref;
		}
		return aref;
	}

	TypeReference MapType (Type t) {
		TypeDefinition td;

		if (t is TypeBuilder && t.Module == moduleb) {
			return type_map [t as TypeBuilder];
		} else if (type_map.TryGetValue (t, out td) && t.Module == moduleb) {
			// Finished types
			return td;
		} else if (t.IsGenericType && !t.IsGenericTypeDefinition) {
			var ginst = new GenericInstanceType (MapType (t.GetGenericTypeDefinition ()));
			foreach (Type arg in t.GetGenericArguments ())
				ginst.GenericArguments.Add (MapType (arg));
			return ginst;
		} else if (t.IsGenericParameter) {
			var gdecl = MapType (t.DeclaringType) as TypeDefinition;
			return gdecl.GenericParameters [t.GenericParameterPosition];
		} else if (t.IsArray) {
			if (!t.IsSzArray)
				return new Mono.Cecil.ArrayType (MapType (t.GetElementType ()), t.GetArrayRank ());
			else
				return new Mono.Cecil.ArrayType (MapType (t.GetElementType ()));
		} else if (t.IsPointer) {
			return new Mono.Cecil.PointerType (MapType (t.GetElementType ()));
		} else {
			IMetadataScope scope;

			// FIXME: Add a cache

			if (t.Assembly == typeof (object).Assembly && t.Namespace == "System") {
				switch (t.Name) {
				case "Object":
					return md.TypeSystem.Object;
				case "Void":
					return md.TypeSystem.Void;
				case "Boolean":
					return md.TypeSystem.Boolean;
				case "Char":
					return md.TypeSystem.Char;
				case "SByte":
					return md.TypeSystem.SByte;
				case "Byte":
					return md.TypeSystem.Byte;
				case "Int16":
					return md.TypeSystem.Int16;
				case "UInt16":
					return md.TypeSystem.UInt16;
				case "Int32":
					return md.TypeSystem.Int32;
				case "UInt32":
					return md.TypeSystem.UInt32;
				case "Int64":
					return md.TypeSystem.Int64;
				case "UInt64":
					return md.TypeSystem.UInt64;
				case "Single":
					return md.TypeSystem.Single;
				case "Double":
					return md.TypeSystem.Double;
				case "IntPtr":
					return md.TypeSystem.IntPtr;
				case "UIntPtr":
					return md.TypeSystem.UIntPtr;
				case "String":
					return md.TypeSystem.String;
				case "TypedReference":
					return md.TypeSystem.TypedReference;
				default:
					break;
				}
			}

			scope = MapAssemblyRef (t.Assembly);
			TypeReference tref = new TypeReference (t.Namespace, t.Name, md, scope, t.IsValueType);
			if (t.IsNested)
				tref.DeclaringType = MapType (t.DeclaringType);

			return tref;
		}
	}

	MarshalInfo MapMarshal (UnmanagedMarshal marshal) {
		switch (marshal.GetUnmanagedType) {
		case UnmanagedType.CustomMarshaler: {
			var custom = new CustomMarshalInfo ();
			custom.Guid = Guid.Empty;
			custom.ManagedType = MapType (marshal.MarshalTypeRef);
			custom.UnmanagedType = marshal.MarshalType;
			custom.Cookie = marshal.MarshalCookie;
			return custom;
		}
		case UnmanagedType.ByValArray: {
			var minfo = new FixedArrayMarshalInfo ();
			minfo.Size = marshal.ElementCount;
			return minfo;
		}
		case UnmanagedType.ByValTStr: {
			var minfo = new FixedSysStringMarshalInfo ();
			minfo.Size = marshal.ElementCount;
			return minfo;
		}
		case UnmanagedType.Bool:
		case UnmanagedType.I1:
		case UnmanagedType.U1:
		case UnmanagedType.I2:
		case UnmanagedType.U2:
		case UnmanagedType.I4:
		case UnmanagedType.U4:
		case UnmanagedType.I8:
		case UnmanagedType.U8:
		case UnmanagedType.R4:
		case UnmanagedType.R8:
			return new MarshalInfo ((NativeType)marshal.GetUnmanagedType);
		default:
			throw new NotImplementedException (marshal.GetUnmanagedType.ToString ());
		}
	}

	FieldDefinition MapField (FieldBuilder fb) {
		var ftype = MapType (fb.FieldType);
		var modOpt = fb.GetModOpt ();
		if (modOpt != null) {
			foreach (var t in modOpt)
				ftype = new OptionalModifierType (MapType (t), ftype);
		}
		var modReq = fb.GetModReq ();
		if (modReq != null) {
			foreach (var t in modReq)
				ftype = new RequiredModifierType (MapType (t), ftype);
		}
		FieldDefinition fd = new FieldDefinition (fb.Name, (Mono.Cecil.FieldAttributes)fb.Attributes, ftype);
		if ((fb.Attributes & System.Reflection.FieldAttributes.HasDefault) != 0)
			fd.Constant = fb.GetConstant ();
		if ((fb.Attributes & System.Reflection.FieldAttributes.HasFieldRVA) != 0)
			fd.InitialValue = fb.GetRVAData ();
		if (fb.GetOffset () != -1)
			fd.Offset = fb.GetOffset ();
		var marshal = fb.GetMarshal ();
		if (marshal != null)
			fd.MarshalInfo = MapMarshal (marshal);

		foreach (var cattrb in fb.GetCustomAttributeBuilders ())
			fd.CustomAttributes.Add (MapCattr (cattrb));

		return fd;
	}

	TypeReference AddModifiers (TypeReference type, Type[] modReq, Type[] modOpt) {
		if (modReq != null) {
			foreach (var t in modReq)
				type = new RequiredModifierType (MapType (t), type);
		}

		if (modOpt != null) {
			foreach (var t in modOpt)
				type = new OptionalModifierType (MapType (t), type);
		}
		return type;
	}

	ParameterDefinition MapParam (MethodBuilder mb, ConstructorBuilder ctor, ParameterInfo param_info) {
		var param_type = MapType (param_info.ParameterType);
		Type[] modReq, modOpt;

		if (ctor != null) {
			modReq = ctor.GetParamModReq (param_info.Position);
			modOpt = ctor.GetParamModOpt (param_info.Position);
		} else {
			modReq = mb.GetParamModReq (param_info.Position);
			modOpt = mb.GetParamModOpt (param_info.Position);
		}
		param_type = AddModifiers (param_type, modReq, modOpt);
		var pd = new ParameterDefinition (param_info.Name, (Mono.Cecil.ParameterAttributes)param_info.Attributes, param_type);
		ParameterBuilder pb;
		if (ctor != null)
			pb = ctor.GetParameterBuilder (param_info.Position + 1);
		else
			pb = mb.GetParameterBuilder (param_info.Position + 1);
		if (pb != null) {
			pd.Constant = pb.GetConstant ();
			var marshal = pb.GetMarshal ();
			if (marshal != null)
				pd.MarshalInfo = MapMarshal (marshal);
			foreach (var cattrb in pb.GetCustomAttributeBuilders ())
				pd.CustomAttributes.Add (MapCattr (cattrb));
		}

		return pd;
	}		

	MethodReference MapMethod (MethodInfo m) {
		if (m is MethodBuilder && m.Module == moduleb)
			return method_map [m];

		var mref = new MethodReference (m.Name, MapType (m.ReturnType), MapType (m.DeclaringType));
		if ((m.CallingConvention & CallingConventions.HasThis) > 0)
			mref.HasThis = true;
		foreach (var param_info in m.GetParameters ())
			mref.Parameters.Add (new ParameterDefinition (param_info.Name, (Mono.Cecil.ParameterAttributes)param_info.Attributes, MapType (param_info.ParameterType)));
		return mref;
	}

	MethodReference MapMethod (ConstructorInfo m) {
		if (m is ConstructorBuilder && m.Module == moduleb)
			// FIXME:
			throw new NotImplementedException ();

		var mref = new MethodReference (m.Name, MapType (typeof (void)), MapType (m.DeclaringType));
		if ((m.CallingConvention & CallingConventions.HasThis) > 0)
			mref.HasThis = true;
		foreach (var param_info in m.GetParameters ())
			mref.Parameters.Add (new ParameterDefinition (param_info.Name, (Mono.Cecil.ParameterAttributes)param_info.Attributes, MapType (param_info.ParameterType)));
		return mref;
	}

	GenericParameter MapGenericParam (IGenericParameterProvider parent, GenericTypeParameterBuilder gparambuilder) {
		var gparam = new GenericParameter (gparambuilder.Name, parent);
		if (gparambuilder.BaseType != null)
			gparam.Constraints.Add (MapType (gparambuilder.BaseType));
		var constraints = gparambuilder.GetInterfaceConstraints ();
		if (constraints != null) {
			foreach (var constraint in constraints)
				gparam.Constraints.Add (MapType (constraint));
		}

		foreach (var cattrb in gparambuilder.GetCustomAttributeBuilders ())
			gparam.CustomAttributes.Add (MapCattr (cattrb));

		return gparam;
	}

	void MapTypeBuilder (TypeBuilder tb) {
		TypeDefinition td = type_map [tb];

		// Parent
		if (tb.BaseType != null)
			td.BaseType = MapType (tb.BaseType);
		// Nested in
		if (tb.DeclaringType != null) {
			td.DeclaringType = type_map [tb.DeclaringType as TypeBuilder];
			td.DeclaringType.NestedTypes.Add (td);
		} else {
			if (tb != global_type)
				md.Types.Add (td);
		}
		// Generic parameters
		Type[] gargs = tb.GetGenericArguments ();
		if (gargs != null) {
			foreach (var t in gargs) {
				td.GenericParameters.Add (MapGenericParam (td, (t as GenericTypeParameterBuilder)));
			}
		}
		// Cattrs
		foreach (var cattrb in tb.GetCustomAttributeBuilders ())
			td.CustomAttributes.Add (MapCattr (cattrb));
		// Nested types
		foreach (TypeBuilder nested_tb in tb.GetNestedTypes (BindingFlags.Public|BindingFlags.NonPublic))
			MapTypeBuilder (nested_tb);
		// Interfaces
		foreach (var t in tb.GetInterfaces ())
			td.Interfaces.Add (new InterfaceImplementation (MapType (t)));
		// Size/Packing Size
		if (tb.Size > 0)
			td.ClassSize = tb.Size;
		if (tb.PackingSize > 0)
			td.PackingSize = (short)tb.PackingSize;
		// Fields
		var fields = tb.GetFieldBuilders ();
		foreach (var fb in fields) {
			if (fb == null)
				continue;
			td.Fields.Add (MapField (fb));
		}
		// Ctors
		foreach (var ctor in tb.GetCtorBuilders ()) {
			if (ctor == null)
				continue;
			var md = new MethodDefinition (ctor.IsStatic ? ".cctor" : ".ctor", (Mono.Cecil.MethodAttributes)ctor.Attributes, MapType (typeof (void)));
			md.ImplAttributes = (Mono.Cecil.MethodImplAttributes)ctor.GetMethodImplementationFlags ();

			foreach (var cattrb in ctor.GetCustomAttributeBuilders ())
				md.CustomAttributes.Add (MapCattr (cattrb));

			td.Methods.Add (md);

			var pars = ctor.GetParametersInternal ();
			if (pars != null) {
				foreach (var param_info in pars)
					md.Parameters.Add (MapParam (null, ctor, param_info));
			}

			// FIXME: Code
			var ilgen = ctor.GetILGen ();
			if (ilgen != null) {
				var body = new Mono.Cecil.Cil.MethodBody (md);
				body.MaxStackSize = ilgen.MaxStack;
				body.InitLocals = true;
				throw new NotImplementedException ();
			}
		}
		// Methods
		foreach (var mb in tb.GetMethodBuilders ()) {
			if (mb == null)
				continue;
			// FIXME: calling conv, pinvoke, return type attrs
			var rtype = AddModifiers (MapType (mb.ReturnType), mb.GetReturnModReq (), mb.GetReturnModOpt ());
			//var md = new MethodDefinition (mb.Name, (Mono.Cecil.MethodAttributes)mb.Attributes, rtype);
			var md = method_map [mb];
			md.ImplAttributes = (Mono.Cecil.MethodImplAttributes)mb.GetMethodImplementationFlags ();

			foreach (var cattrb in mb.GetCustomAttributeBuilders ())
				md.CustomAttributes.Add (MapCattr (cattrb));

			// Generic parameters
			gargs = mb.GetGenericArguments ();
			if (gargs != null) {
				foreach (var t in gargs)
					md.GenericParameters.Add (MapGenericParam (md, (t as GenericTypeParameterBuilder)));
			}

			var m_ret = new MethodReturnType (md);
			m_ret.ReturnType = rtype;
			md.MethodReturnType = m_ret;

			var retparam = mb.GetParameterBuilder (0);
			if (retparam != null) {
				var marshal = retparam.GetMarshal ();
				if (marshal != null) {
					m_ret.Attributes |= Mono.Cecil.ParameterAttributes.HasFieldMarshal;
					m_ret.MarshalInfo = MapMarshal (marshal);
				}
				foreach (var cattrb in retparam.GetCustomAttributeBuilders ())
					m_ret.CustomAttributes.Add (MapCattr (cattrb));
			}

			var pars = mb.GetParametersInternal ();
			if (pars != null) {
				foreach (var param_info in pars)
					md.Parameters.Add (MapParam (mb, null, param_info));
			}

			foreach (var m in mb.GetOverrides ())
				md.Overrides.Add (MapMethod (m));

			td.Methods.Add (md);
		}
		// Properties
		foreach (var pb in tb.GetPropertyBuilders ()) {
			// FIXME: cmod, cconv, other methods
			var pd = new PropertyDefinition (pb.Name, (Mono.Cecil.PropertyAttributes)pb.Attributes, MapType (pb.PropertyType));
			pd.GetMethod = (MethodDefinition)MapMethod (pb.GetGetMethod ());
			pd.SetMethod = (MethodDefinition)MapMethod (pb.GetSetMethod ());
			pd.Constant = pb.GetConstant ();

			foreach (var cattrb in pb.GetCustomAttributeBuilders ())
				pd.CustomAttributes.Add (MapCattr (cattrb));

			td.Properties.Add (pd);
		}
		// Events
		foreach (var eb in tb.GetEventBuilders ()) {
			var eventd = new EventDefinition (eb.Name, (Mono.Cecil.EventAttributes)eb.Attributes, MapType (eb.EventType));
			eventd.AddMethod = (MethodDefinition)MapMethod (eb.add_method);
			eventd.RemoveMethod = (MethodDefinition)MapMethod (eb.remove_method);
			eventd.InvokeMethod = (MethodDefinition)MapMethod (eb.raise_method);

			foreach (var cattrb in eb.GetCustomAttributeBuilders ())
				eventd.CustomAttributes.Add (MapCattr (cattrb));

			td.Events.Add (eventd);
		}
	}
}
