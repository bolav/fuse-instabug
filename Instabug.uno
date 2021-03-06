using Uno;
using Uno.UX;
using Uno.Collections;
using Uno.Compiler.ExportTargetInterop;
using Fuse;
using Fuse.Triggers;
using Fuse.Controls;
using Fuse.Controls.Native;
using Fuse.Controls.Native.Android;

using Fuse.Platform;

[Require("Cocoapods.Podfile.Target", "pod 'Instabug'")]
[extern(ios) ForeignInclude(Language.ObjC, "Instabug/Instabug.h")]
public class FuseInstabug : Behavior {
    public FuseInstabug () {
        if defined(DESIGNMODE)
            return;
        if ((Fuse.Platform.Lifecycle.State == Fuse.Platform.ApplicationState.Foreground)
            || (Fuse.Platform.Lifecycle.State == Fuse.Platform.ApplicationState.Interactive)
            ) {
            _foreground = true;
        }
        else {
            Fuse.Platform.Lifecycle.EnteringForeground += OnEnteringForeground;
        }
    }

    void OnEnteringForeground(Fuse.Platform.ApplicationState newState)
    {
        _foreground = true;
        Fuse.Platform.Lifecycle.EnteringForeground -= OnEnteringForeground;
        Init();
    }

    static bool _foreground = false;
    static bool _inited = false;
    void Init() {
        debug_log "Init";
        if defined(DESIGNMODE)
            return;
        if (_inited)
            return;
        if (Token == null) {
            return;
        }
        if (!_foreground)
            return;
        _inited = true;
        if defined(iOS) 
            InitImpl(Token);
    }

    [Foreign(Language.ObjC)]
    extern(iOS) void InitImpl(string token) 
    @{
        [Instabug startWithToken:token invocationEvent:IBGInvocationEventShake];
    @}

    static string _token;
    public string Token {
        get { return _token; } 
        set { 
            _token = value;
            Init();
        }
    }
}
