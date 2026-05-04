/**
LibPQPath:
    Places where LibPQ will search for modules.

    Local sources have priority over Web sources.
    Local and Web locations must be listed in the priority order: from
    high to lower priority.
**/
[
    Local = {
       // "C:\Users\ciden\OneDrive - laurelridge.edu\Documents\Power Query Files\Libraries\LibPQ\LibPQ-master\Modules",
       // "C:\Users\ciden\OneDrive - laurelridge.edu\Documents\Power Query Files\Libraries\LibPQ\LibPQ-master\Tests",
      //  "C:\Users\ciden\OneDrive - laurelridge.edu\Documents\Power Query Files\Libraries\pquery-master"
        //    "D:\ExtractLocation\LibPQ\Modules",
        //    "D:\ExtractLocation\LibPQ\Tests"
    },
    Web = {
        "https://github.com/sio/LibPQ/raw/master/Modules/",
        "https://github.com/ciden6481/CustomFunctionsLibrary/raw/master/Modules/"
        // "https://github.com/tycho01/pquery/raw/master/",
    }
]
