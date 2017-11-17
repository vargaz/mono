
all:

# Build % from assemblies %_ASSEMBLIES
# The end result is in bin/ios-sim/test-%.app
build-ios-sim-%:
	make -C test-runner/
	rm -rf tmp.app
	mkdir -p tmp.app
	cp test-runner/test-runner tmp.app/test-$*
	cp test-runner/Info.plist.in tmp.app/1
	sed -e "s/BUNDLE_IDENTIFIER/com.xamarin.mono.ios.test-$*/g" < tmp.app/1 > tmp.app/2
	sed -e "s/BUNDLE_EXECUTABLE/test-$*/g" < tmp.app/2 > tmp.app/3
	sed -e "s/BUNDLE_NAME/test-$*/g" < tmp.app/3 > tmp.app/Info.plist
	rm -f tmp.app/{1,2,3}
	plutil -convert binary1 tmp.app/Info.plist 
	cp -r test-runner/Base.lproj tmp.app
	cp ../../mcs/class/lib/monotouch/{mscorlib.dll,System.dll,System.Xml.dll,System.Core.dll,Mono.Simd.dll,System.Numerics.dll,System.Numerics.Vectors.dll,nunitlite.dll,nunit-lite-console.exe} tmp.app
	cp $($*_ASSEMBLIES) tmp.app
	/usr/bin/codesign --force --sign - --timestamp=none tmp.app
	mkdir -p bin/ios-sim
	rm -rf bin/ios-sim/test-$*.app
	mv tmp.app bin/ios-sim/test-$*.app

# Install % on the simulator
install-ios-sim-%:
	xcrun simctl install booted bin/ios-sim/test-$*.app

# Clean %
clean-ios-sim-%:
	$(RM) -rf bin/ios-sim/test-$*.app

# Run % on the simulator with args %_ARGS
run-ios-sim-%:
	xcrun simctl terminate booted com.xamarin.mono.ios.test-$*
	xcrun simctl launch --console booted com.xamarin.mono.ios.test-$* $($*_ARGS)

clean:
	$(MAKE) -C test-runner clean
	$(RM) -rf bin

start-sim:
	xcrun simctl boot 94619BF8-ED9C-4A14-BA8C-6A22140ABA2C

stop-sim:
	xcrun simctl shutdown booted

# Options for each test
Mono.Runtime.Tests_ASSEMBLIES = ../../mcs/class/lib/monotouch/tests/monotouch_Mono.Runtime.Tests_test.dll
Mono.Runtime.Tests_ARGS = nunit-lite-console.exe monotouch_Mono.Runtime.Tests_test.dll
