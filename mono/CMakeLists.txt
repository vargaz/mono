project (mono)

set (subdirs eglib arch utils cil sgen metadata mini dis profiler)

foreach (dir ${subdirs})
  add_subdirectory (${dir})
endforeach ()
