--
-- xmonad example config file.
--
-- A template showing all available configuration hooks,
-- and how to override the defaults in your own xmonad.hs conf file.
--
-- Normally, you'd only override those defaults you care about.
--

--
-- XMonad core
--
-- These `import`s can be replaced with only one `import XMonad` line.
--

import XMonad

-- Other required modules
import qualified XMonad.StackSet as W
import qualified Data.Map as M

-- Algorithms
import Control.Monad(liftM)
import Data.Char(toLower)
import Data.List(isPrefixOf)

-- System
import qualified System.Exit as Exit
import qualified System.IO
import qualified XMonad.Util.Run as Run
import qualified System.Posix.Env as Env

-- Hooks
import qualified XMonad.Hooks.DynamicLog as DynamicLog
import qualified XMonad.Hooks.ManageDocks as ManageDocks
import qualified XMonad.Hooks.SetWMName as Hooks
import qualified XMonad.Hooks.EwmhDesktops as EwmhDesktops
import qualified XMonad.Hooks.InsertPosition as InsertPosition
import qualified XMonad.Hooks.ManageHelpers as ManageHelpers

-- Layouts
import qualified XMonad.Layout.Gaps as Gaps
import qualified XMonad.Layout.NoBorders as NoBorders
import qualified XMonad.Layout.Magnifier as Magnifier
import qualified XMonad.Layout.MultiToggle as MultiToggle
import qualified XMonad.Layout.MultiToggle.Instances as MultiToggle
import qualified XMonad.Layout.ThreeColumns as ThreeColumns
import qualified XMonad.Layout.Renamed as Renamed
import qualified XMonad.Layout.Tabbed as Tabbed
import qualified XMonad.Layout.HintedTile as HintedTile

-- Utils
import qualified XMonad.Util.Dmenu as Dmenu
import qualified XMonad.Util.WorkspaceCompare as WorkspaceCompare
import qualified Graphics.X11.Xlib as Xlib
import qualified Graphics.X11.Xinerama as Xinerama
import Graphics.X11.ExtraTypes.XF86
import qualified XMonad.Actions.GridSelect as GridSelect
import qualified XMonad.Prompt as Prompt
import qualified XMonad.Prompt.Shell as Prompt
import qualified XMonad.Prompt.Input as Prompt
import XMonad.Prompt.Input((?+))
import qualified XMonad.Util.Themes as Themes
import qualified XMonad.Actions.Submap as Actions
import qualified XMonad.Actions.DynamicWorkspaces as DynamicWorkspaces
import qualified XMonad.Actions.CopyWindow as CopyWindow


-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--
spawnInTerminal :: String -> [String] -> X ()
-- For mlterm.
--myTerminal      = "mlterm"
--spawnInTerminal cmd opts = Run.safeSpawn myTerminal $ "-e":cmd:opts
-- For alacritty.
myTerminal      = "/home/larry/.cargo/bin/alacritty"
spawnInTerminal cmd opts = Run.safeSpawn myTerminal $ "-e":cmd:opts

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- Width of the window border in pixels.
--
myBorderWidth   = 1

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask       = mod4Mask

-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
-- A tagging example:
--
-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
--
myWorkspaces    = map show [1..9] ++ ["bg"]

-- Border colors for unfocused and focused windows, respectively.
--
myNormalBorderColor  = "#dddddd"
myFocusedBorderColor = "#ff0000"

-- Xft font.
myXftFont = "xft:VL Gothic"
sizedXftFont :: Int -> String
sizedXftFont size = myXftFont ++ ":size=" ++ show size

-- XMonad Prompt config.
--myXPConfig = amberXPConfig { font = sizedXftFont 9 }
--myXPConfig = greenXPConfig { font = sizedXftFont 9 }
myXPConfig = Prompt.amberXPConfig {
  Prompt.font = sizedXftFont 9,
  Prompt.promptKeymap = M.union (Prompt.promptKeymap Prompt.amberXPConfig) $ M.fromList $
    [ ((controlMask, xK_h ), Prompt.deleteString Prompt.Prev)
    , ((controlMask, xK_d ), Prompt.deleteString Prompt.Next)
    , ((controlMask, xK_b ), Prompt.moveCursor Prompt.Prev)
    , ((controlMask, xK_f ), Prompt.moveCursor Prompt.Next)
    , ((controlMask, xK_m ), Prompt.setSuccess True >> Prompt.setDone True)
    ]
}

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
myToggleStrutsKey XConfig { modMask = modm } = (modm , xK_b)
myKeys conf@(XConfig {modMask = modm}) = M.fromList $

    -- launch a terminal
    [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)

    -- launch dmenu
    , ((modm,               xK_p     ), Run.safeSpawn "zsh" ["-ic", "dmenu_run"])

    -- launch gmrun
    , ((modm .|. shiftMask, xK_p     ), Run.safeSpawn "zsh" ["-ic", "rofi -show drun"])

    -- close focused window
    , ((modm .|. shiftMask, xK_c     ), kill)

     -- Rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)

    -- Move focus to the next window
    --, ((modm,               xK_Tab   ), windows W.focusDown)

    -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown)

    -- Move focus to the previous window
    , ((modm,               xK_k     ), windows W.focusUp  )

    -- Move focus to the master window
    , ((modm,               xK_m     ), windows W.focusMaster  )

    -- Swap the focused window and the master window
    , ((modm,               xK_Return), windows W.swapMaster)

    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )

    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )

    -- Shrink the master area
    , ((modm,               xK_h     ), sendMessage Shrink)

    -- Expand the master area
    , ((modm,               xK_l     ), sendMessage Expand)

    -- Push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))

    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    --
    -- NOTE: Use statusBar and myToggleStrutsKey instead.
    --
    -- , ((modm              , xK_b     ), sendMessage ToggleStruts)

    -- Quit xmonad
    --, ((modm .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))
    , ((modm .|. shiftMask, xK_q     ), exitWithConfirm Exit.ExitSuccess)

    -- Restart xmonad
    -- `xmonad --restart` may automatically recompile this configure file.
    , ((modm              , xK_q     ), spawn "LANG=C xmonad --recompile && xmonad --restart")

    -- Run xmessage with a summary of the default keybindings (useful for beginners)
    , ((modm .|. shiftMask, xK_slash ), messageBox "help" help)
    ]
    ++

    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (workspaces conf) ([xK_1 .. xK_9] ++ [xK_0])
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

    --
    -- larry's setting
    --
    ++
    -- 'L'ock screen
    [ ((modm .|. shiftMask, xK_l     ), Run.safeSpawn "xscreensaver-command" ["-lock"])
    -- Capture window
    , ((0                 , xK_Print ), spawn "import -frame ~/Pictures/screenshots/`date '+screenshot-%Y-%m-%d-%H%M%S%z.png'`")
    -- Capture screen
    --, ((modm              , xK_Print ), spawn "import -screen ~/Pictures/`date '+screenshot-%Y-%m-%d-%H%M%S%z.png'`")
    , ((modm              , xK_Print ), Run.safeSpawn "scrot" ["-m", "screenshot-%Y-%m-%d-%H%M%S%z.png", "-e", "mv $f ~/Pictures/screenshots/"])
    -- Run 'F'iler
    --, ((modm              , xK_f     ), Run.safeSpawn "nautilus" ["--new-window"])
    , ((modm              , xK_f     ), Run.safeSpawnProg "pcmanfm")
    -- Run 'F'iler as root
    , ((modm .|. shiftMask, xK_f     ), Run.safeSpawn "gksu" ["pcmanfm"])
    -- 'Q'uit xmonad without warning
    , ((modm .|. shiftMask .|. controlMask, xK_q ), io (Exit.exitWith Exit.ExitSuccess))
    -- Eject DVD
    , ((0                 , xF86XK_Eject ), Run.safeSpawn "eject" ["-T", "/dev/sr0"])
    ]

    --
    -- settings for laptop
    --
    -- ++
    -- [ ((0                 , xF86XK_MonBrightnessUp ), Run.safeSpawn "xbacklight" ["-steps", "1", "-inc", "9"])
    -- , ((0                 , xF86XK_MonBrightnessDown ), Run.safeSpawn "xbacklight" ["-steps", "1", "-dec", "9"])
    -- ]

    --
    -- volume control
    --
    ++
    [ ((0                 , xF86XK_AudioMute ), spawn "~/scripts/local/volumecontrol.sh toggle")
    , ((0                 , xF86XK_AudioRaiseVolume ), spawn "~/scripts/local/volumecontrol.sh 1%+")
    , ((0                 , xF86XK_AudioLowerVolume ), spawn "~/scripts/local/volumecontrol.sh 1%-")
    ]

    --
    -- MPD control
    --
    ++
    [ ((0                 , xF86XK_AudioPause ), spawn "~/scripts/local/mpd.sh toggle_pause")
    , ((modm              , xK_Pause ), spawn "~/scripts/local/mpd.sh toggle_pause")
    , ((modm              , xF86XK_AudioRaiseVolume ), spawn "~/scripts/local/mpd.sh set_volume +3")
    , ((modm              , xF86XK_AudioLowerVolume ), spawn "~/scripts/local/mpd.sh set_volume -3")
    , ((0                 , xF86XK_AudioPlay ), spawn "~/scripts/local/mpd.sh set_play_status play")
    , ((0                 , xF86XK_AudioStop ), spawn "~/scripts/local/mpd.sh set_play_status stop")
    , ((0                 , xF86XK_AudioPrev ), spawn "~/scripts/local/mpd.sh play previous")
    , ((0                 , xF86XK_AudioNext ), spawn "~/scripts/local/mpd.sh play next")
    , ((modm .|. shiftMask, xK_Pause ), spawn "~/scripts/local/mpd.sh play next")
    ]

    --
    -- window layout control
    --
    ++
    -- Increase magnification rate
    -- Shift-= => '+'
    [ ((modm              , xK_equal ), sendMessage Magnifier.MagnifyMore)
    -- Decrease magnification rate
    , ((modm              , xK_minus ), sendMessage Magnifier.MagnifyLess)
    -- Toggle magnification ('S'caling) on/off
    , ((modm              , xK_s ), sendMessage Magnifier.Toggle)
    -- Toggle full
    , ((modm              , xK_F12 ), sendMessage $ MultiToggle.Toggle MultiToggle.NBFULL)
    -- Toggle vertical and horizontal ('M'irror)
    , ((modm .|. controlMask, xK_m ), sendMessage $ MultiToggle.Toggle MultiToggle.MIRROR)
    -- Select window and focus ('G'rid)
    , ((modm              , xK_g ),
        GridSelect.gridselectWindow def
        >>= flip whenJust (\w -> focus w >> windows (W.focusWindow w))
      )
    ]

    --
    -- clipboard
    --
    -- ++
    -- Paste from clipboard, not from selection
    -- (Paste from selection with Shift-Insert)
    -- NOTE: `pasteString` は空白文字を無視するようなので、現状では意図したようにpasteできない。
    -- [ ((controlMask       , xK_Insert ), runProcessWithInput "xsel" ["--clipboard", "--output"] "" >>= pasteString)
    -- , ((modm              , xK_Insert ), runProcessWithInput "xsel" ["--clipboard", "--output"] "" >>= pasteString)
    -- ]

    --
    -- Dynamic workspace control
    --
    ++
    -- Remove workspace
    [ ((modm .|. shiftMask, xK_BackSpace), DynamicWorkspaces.removeWorkspace)
    -- Select workspace with prompt
    , ((modm .|. shiftMask, xK_v        ), DynamicWorkspaces.selectWorkspace myXPConfig)
    -- Select workspace with gridselect
    , ((modm .|. controlMask, xK_v      ), GridSelect.gridselectWorkspace def W.greedyView)
    -- 'W'orkspace operations
    , ((modm .|. controlMask, xK_w      ), Actions.submap . M.fromList $
      -- 'M'ove selected window to another workspace
      [ ((modm                , xK_m      ), DynamicWorkspaces.withWorkspace myXPConfig (windows . W.shift))
      -- 'C'opy window to another workspace
      , ((modm                , xK_c        ), DynamicWorkspaces.withWorkspace myXPConfig (windows . CopyWindow.copy))
      ])
    -- Rename current workspace
    , ((modm .|. shiftMask, xK_r        ), DynamicWorkspaces.renameWorkspace myXPConfig)
    ]

    --
    -- other
    --
    ++
    -- 'S'hell prompt on the bottom of the screen.
    [ ((modm .|. shiftMask, xK_s ), Prompt.shellPrompt myXPConfig)
    -- Select frequently used applications with grid.
    , ((modm              , xK_Tab ), GridSelect.runSelectedAction def
        [ ("firefox"        , systemdScopeRunFirefox)
        , ("thunderbird"    , Run.safeSpawnProg "thunderbird")
        , ("pcmanfm"        , Run.safeSpawnProg "pcmanfm")
        , ("pavucontrol"    , Run.safeSpawnProg "pavucontrol")
        , ("arandr"         , Run.safeSpawnProg "arandr")
        , ("cantana"        , Run.safeSpawnProg "cantata")
        , ("WLAN reconnect" , Run.safeSpawn "rofi" ["-modi", "Wifi:~/scripts/rofi-wifi.sh", "-show", "Wifi"])
        , ("hybrid-sleep"   , Run.safeSpawn "systemctl" ["hybrid-sleep"])
        , ("display sleep"  , Run.safeSpawn "xset" ["dpms", "force", "off"])
        , ("keepassxc"      , Run.safeSpawnProg "keepassxc")
        ]
      )
    -- Select an existing session with grid.
    , ((modm              , xK_semicolon), termAttachTmuxSession)
    -- Specify session to attach or create with prompt.
    , ((modm .|. shiftMask, xK_semicolon), tmuxSessionPrompt)
    -- Copy unicode character.
    , ((modm              , xK_u     ), Run.safeSpawn "rofi" ["-modi", "Emoji:~/scripts/emoji-prompt.sh", "-show", "Emoji"])
    ]

------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    , ((modm, 12 :: Xlib.Button), (\w -> focus w >> kill))
    ]

------------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
--myLayout = tiled ||| Mirror tiled ||| Full
myLayout =
    MultiToggle.mkToggle1 MultiToggle.NBFULL
    $ MultiToggle.mkToggle1 MultiToggle.MIRROR
    -- Do not show window border when there is only one window shown.
    $ NoBorders.smartBorders
    -- Avoid covering docks (status bars)
    -- XMonad.Config.DesktopのdesktopLayoutModifiersを使うと、MultiToggleのMIRRORで何故か横幅がおかしくなる。
    -- $ desktopLayoutModifiers
    -- I want ``ModifiedLayout (Mag (1.2, 1.2) Off NoMaster)``
    -- (1.2x1.2 size, default off, master is not magnified),
    -- but ModifiedLayout, Mag, Off and NoMaster aren't exported.
    $ (mag $ tiled)
    ||| (mag $ threeCol)
    ||| Renamed.renamed [Renamed.Replace "tabbed"] (Tabbed.tabbed Tabbed.shrinkText tabbedLayout)
    where
       -- default tiling algorithm partitions the screen into two panes
       --tiled   = Tall nmaster delta ratio
       -- Hinted tile
       tiled   = HintedTile.HintedTile nmaster delta ratio HintedTile.Center HintedTile.Tall
       --tiled   = Gaps.gaps [(Gaps.D, 18)] $ HintedTile.HintedTile nmaster delta ratio HintedTile.Center HintedTile.Tall

       -- Three column
       threeCol = ThreeColumns.ThreeCol nmaster delta ratio

       -- Magnifier
       --mag = Mag.magnifiercz' 1.1
       mag = Magnifier.magnifiercz' 1

       -- Theme for tabbed layout
       tabbedLayout = (Themes.theme Themes.robertTheme) { Tabbed.fontName = sizedXftFont 8 }
       --tabbedLayout = (theme donaldTheme) { fontName = sizedXftFont 8 }
       --tabbedLayout = (theme wfarrTheme) { fontName = sizedXftFont 8 }

       -- No border for full screen window
       --full    = noBorders Full

       -- The default number of windows in the master pane
       nmaster = 1

       -- Default proportion of screen occupied by master pane
       ratio   = 1/2

       -- Percent of screen to increment by when resizing panes
       delta   = 3/100

------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'appName' are used below.
--
myManageHook = composeAll . concat $
    [ [ className =? c --> doFocus | c <- myFocus ]
    -- Open new window after active window and don't change active window
    -- except when the new window is not a dialog.
    , [ not `liftM` ManageHelpers.isDialog --> InsertPosition.insertPosition InsertPosition.Below InsertPosition.Older]
    , [ManageDocks.manageDocks]
    --, [manageHook defaultConfig]
    , [manageHook def]
    , [ className =? c --> doFloat | c <- myFloats ]
    , [ appName  =? r --> doIgnore | r <- myIgnores ]
    , [ className =? "Firefox" <&&> appName =? "Dialog" --> doFloat ]
    , [ className =? "Gkrellm" <&&> appName =? "Gkrellm_conf" --> doFloat ]
    , [ className =? "Thunar" <&&> title =? "ファイル操作進行中" --> doFloat ]
    , [ className =? "Dia" <&&> role =? "toolbox_window" --> doFloat ]
    , [ role =? r  --> doFloat | r <- myFloatRole ]
    ]
    where
      myFloats = ["MPlayer", "Conky", "Tilda", "Zenity", "StepMania", "Qjackctl"]
      myIgnores = ["desktop_window", "kdesktop"]
      myFloatRole = ["gimp-message-dialog"]
      role = stringProperty "WM_WINDOW_ROLE"
      doFocus = InsertPosition.insertPosition InsertPosition.Below InsertPosition.Newer
      myFocus = ["Gcr-prompter", "Pinentry-gtk-2", "Pinentry"]

------------------------------------------------------------------------
-- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
{-myEventHook = mempty-}
myEventHook = EwmhDesktops.ewmhDesktopsEventHook

------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--
{-myLogHook = return ()-}
myLogHook = EwmhDesktops.ewmhDesktopsLogHook
myXmobarPP = DynamicLog.xmobarPP
        { DynamicLog.ppCurrent = DynamicLog.xmobarColor "#ffff00" "" . DynamicLog.wrap "[" "]"
        , DynamicLog.ppTitle   = DynamicLog.xmobarColor "#00ff00" "" . DynamicLog.shorten 256
        , DynamicLog.ppSort    = WorkspaceCompare.getSortByXineramaRule
        }

------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
--myStartupHook = return ()
--myStartupHook = setWMName "LG3D"
--myStartupHook = ewmhDesktopsStartup >> setWMName "LG3D"
myStartupHook :: X ()
myStartupHook = do
    EwmhDesktops.ewmhDesktopsStartup
    Hooks.setWMName "LG3D"
    screenSizes <- myScreenSizes
    -- Let java VM know about xmonad.
    -- Necessary to use java gui application on XMonad.
    liftIO $ Env.putEnv "_JAVA_AWT_WM_NONREPARENTING=1"
    -- To run tmux in X session started on tmux, erase $TMUX environment variable.
    liftIO $ Env.unsetEnv "TMUX"

    Run.safeSpawn "xsetroot" ["-cursor_name", "left_ptr"]
    spawn "xkbcomp ~/.lifebook_keyboard_lite.xkm :0"
    spawn $
        "ps -A -w -w --no-header -o pid,command=WIDE-COMMAND-COLUMN"
        ++ " | grep '[/]scripts/local/status.sh '\"$DISPLAY\"'$'"
        ++ " | awk '{print $1}' | xargs -r kill"
        ++ " ; " ++ myDzenCommandLine (head screenSizes)
    spawn "gpg-connect-agent updatestartuptty /bye >/dev/null"

------------------------------------------------------------------------
-- Status bars
myScreenSizes :: X [Xlib.Rectangle]
myScreenSizes = liftIO $ openDisplay "" >>= Xinerama.getScreenInfo
myDzenCommandLine :: Xlib.Rectangle -> String
myDzenCommandLine rect =
    "~/scripts/local/status.sh \"$DISPLAY\""
    ++ " | dzen2 -dock -fn 'VLGothic-10:Bold' -h " ++ show height ++" -ta r -y " ++ show (rect_height rect - height) ++ " -e 'button3=exec:'"
    where height = 16

------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify. No need to modify this.
--
--main = xmonad defaults
--main = xmonad =<< xmobar defaults
--main = xmonad =<< dzen defaults
main = do
    xmproc <- Run.spawnPipe "xmobar ~/.xmobarrc"
    xmonad =<< DynamicLog.statusBar
        "xmobar"
        myXmobarPP
        myToggleStrutsKey
        defaults
        { logHook = DynamicLog.dynamicLogWithPP myXmobarPP {
              DynamicLog.ppOutput = Run.hPutStrLn xmproc
          }
        }

------------------------------------------------------------------------
-- pretty print

------------------------------------------------------------------------


------------------------------------------------------------------------
-- warn before quitting xmonad
--
exitWithConfirm :: Exit.ExitCode -> X ()
exitWithConfirm s = withConfirm "quit Xmonad?" $ io (Exit.exitWith s)

withConfirm :: String -> X () -> X ()
--withConfirm msg f = whenX (confirm_dmenu msg) f
withConfirm = whenX . confirm_dmenu

confirm_dmenu :: String -> X Bool
confirm_dmenu msg = isStringYes `liftM` Dmenu.dmenu [msg, "y", "n"]
    -- Note that return value of function 'dmenu' have \n as last character.
    where isStringYes = (`elem` yess) . map toLower . filter (/= '\n')
          yess = ["y", "yes"]

------------------------------------------------------------------------
-- utilities
spawnStdout :: MonadIO m => String -> String -> m ()
spawnStdout prog input = liftIO $ Run.spawnPipe prog >>= (\h -> Run.hPutStrLn h input >> System.IO.hClose h)

messageBox :: MonadIO m => String -> String -> m ()
messageBox title msg = spawnStdout cmd msg
    where cmd = "xmessage -file - -default okay"

escapeShellArg :: String -> String
escapeShellArg = foldr escapeChar ""
  where escapeChar x = case x of
          '\\' -> ("\\\\" ++)
          ' '  -> ("\\ " ++)
          '"'  -> ("\\\"" ++)
          x    -> (x :)

termTmuxSession :: String -> X ()
termTmuxSession s = spawnInTerminal "sh" ["-c", ("tmux -2 new-session -d -s " ++ name ++ " ; exec tmux -2 attach-session -t =" ++ name)]
    where name = escapeShellArg s

-- Get tmux sessions.
tmuxSessionsList :: MonadIO m => m [String]
tmuxSessionsList = lines `liftM` Run.runProcessWithInput "tmux" ["list-sessions", "-F", "#S"] ""

-- Get tmux sessions and its status.
tmuxSessionsList' :: MonadIO m => m [(String, String)]
tmuxSessionsList' = (map proc . lines) `liftM` Run.runProcessWithInput "tmux" ["list-sessions", "-F", "#{session_attached} #S"] ""
    where proc str = (sname str, sstat str)
          sname = tail . dropWhile (/= ' ')
          sstat str = if (isPrefixOf "0 " str)
                         then "detached"
                         else "attached"

termAttachTmuxSession :: X ()
--termAttachTmuxSession = map genAction `liftM` tmuxSessionsList >>= runSelectedAction def
--    where genAction sname = (sname, termTmuxSession sname)
termAttachTmuxSession = map genAction `liftM` tmuxSessionsList' >>= GridSelect.runSelectedAction def
    where genAction (sname, sstat) = (sname ++ " [" ++ sstat ++ "]", termTmuxSession sname)

tmuxSessionPrompt :: X ()
tmuxSessionPrompt =
    tmuxSessionsList >>=
    (\ss -> Prompt.inputPromptWithCompl myXPConfig "tmux session" (Prompt.mkComplFunFromList' ss)
            ?+ termTmuxSession)

systemdScopeRun :: Maybe String -> [String] -> X ()
systemdScopeRun slice cmdline = Run.safeSpawn "systemd-run" $ ["--user", "--scope"] ++ (sliceToList slice) ++ ["--"] ++ cmdline
    where sliceToList Nothing = []
          sliceToList (Just v) = ["--slice=" ++ v]

systemdScopeRunFirefox :: X ()
systemdScopeRunFirefox = systemdScopeRun (Just "firefox") ["firefox"]
------------------------------------------------------------------------


-- A structure containing your configuration settings, overriding
-- fields in the default config. Any you don't override, will
-- use the defaults defined in xmonad/XMonad/Config.hs
--
-- No need to modify this.
--
--defaults = ewmh $ defaultConfig {
defaults = def {
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

      -- key bindings
        keys               = myKeys,
        mouseBindings      = myMouseBindings,

      -- hooks, layouts
        layoutHook         = myLayout,
        manageHook         = myManageHook,
        handleEventHook    = myEventHook,
        logHook            = myLogHook,
        startupHook        = myStartupHook
    }

-- | Finally, a copy of the default bindings in simple textual tabular format.
help :: String
help = unlines ["The default modifier key is 'alt'. Default keybindings:",
    "",
    "-- launching and killing programs",
    "mod-Shift-Enter  Launch xterminal",
    "mod-p            Launch dmenu",
    "mod-Shift-p      Launch rofi",
    "mod-Shift-c      Close/kill the focused window",
    "mod-Space        Rotate through the available layout algorithms",
    "mod-Shift-Space  Reset the layouts on the current workSpace to default",
    "mod-n            Resize/refresh viewed windows to the correct size",
    "",
    "-- move focus up or down the window stack",
    --"mod-Tab        Move focus to the next window",
    --"mod-Shift-Tab  Move focus to the previous window",
    "mod-j          Move focus to the next window",
    "mod-k          Move focus to the previous window",
    "mod-m          Move focus to the master window",
    "",
    "-- modifying the window order",
    "mod-Return   Swap the focused window and the master window",
    "mod-Shift-j  Swap the focused window with the next window",
    "mod-Shift-k  Swap the focused window with the previous window",
    "",
    "-- resizing the master/slave ratio",
    "mod-h  Shrink the master area",
    "mod-l  Expand the master area",
    "",
    "-- floating layer support",
    "mod-t  Push window back into tiling; unfloat and re-tile it",
    "",
    "-- increase or decrease number of windows in the master area",
    "mod-comma  (mod-,)   Increment the number of windows in the master area",
    "mod-period (mod-.)   Deincrement the number of windows in the master area",
    "",
    "-- quit, or restart",
    "mod-Shift-q  Quit xmonad",
    "mod-q        Restart xmonad",
    "mod-[1..9]   Switch to workSpace N",
    "",
    "-- Workspaces & screens",
    "mod-Shift-[1..9]   Move client to workspace N",
    "mod-{w,e,r}        Switch to physical/Xinerama screens 1, 2, or 3",
    "mod-Shift-{w,e,r}  Move client to screen 1, 2, or 3",
    "",
    "-- Mouse bindings: default actions bound to mouse events",
    "mod-button1  Set the window to floating mode and move by dragging",
    "mod-button2  Raise the window to the top of the stack",
    "mod-button3  Set the window to floating mode and resize by dragging"]
