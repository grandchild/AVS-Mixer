# AVS-Mixer

![Mixer-GUI](https://github.com/grandchild/AVS-Mixer/raw/master/etc/MixerComplete1.png)

A screencast demonstrating some of the features of the AVS-Mixer can be found at: http://vimeo.com/video/45865498

### Prerequisites
You need [VVVV](http://vvvv.org/downloads). You will also need the Addonpack on that same page. Follow the installation instructions for VVVV.

Windows Aero mode is strongly recommended (only available with Windows Vista and 7) because only that allows the screengrabbing of obstructed windows. Otherwise you would need to lay out the windows side-by-side which is very space-consuming.


This was made for, and is most rewarding with, mixing AVS, so a small guide for...
# Setting up AVS
## Installation
### Prepared folder structure (when using XMPlay, for Winamp see below)
In the /etc folder is a zip containing a premade folder structure for you to use. Inside the XMPlayAVS folder you will find a winamp.ini containing recommended AVS settings as well as two folders for skins and plugins. Put all XMPlay files in this folder and all plugins (AVS, VisWrapper & others) inside the plugin folder.

### Get and setup XMPlay
[XMPlay](http://support.xmplay.com/index.php) is the recommended host for AVS right now because it is minimal and keeps AVS in it's own separate native Win32 window - which is better for grabbing.

* Install XMPlay to the above-mentioned directory so that there is a folder named 'XMPlay' in the base folder.
* Next, you need the wrapper plug-ins for XMPlay, [Winamp VIS Wrapper rev.5 by Barna](http://www.nukular.ch/xmp-wavis_rev.5.zip).
* I recommend using a small skin for XMPlay, so it does not get in your way too much: I use [Smallskin 2](http://support.xmplay.com/files_view.php?file_id=308) but there are more (e.g. [Min](http://support.xmplay.com/files_view.php?file_id=546)).

### Using AVS-Mixer with Winamp
* If for some reason you want to use Winamp, you need to use Winamp of version 5.58 or older, as newer versions don't play nicely with AVS anymore. Any Winamp 5.x version should do. It should also come with a working AVS plugin installed so you could in theory be able to skip the next section.

### Choosing your AVS's flavour
* [Visbot kindly provides](http://avs.visbot.net/) close to all versions of AVS ever published. One of the 2.81 versions is recommended. Try d or b (or if you like a slightly different editor interface choose one of visbot's vis_avsmods further down).
* Extract all the versions you'd like to try into the plugin directory next to the XMPlay directory.
* You can now select a version to use from the vis-wrapper's configuration dialog (found in XMPlay's options).

### player-independent
* And if you want to play any source of audio (like from a DJ next to you, or the music from another player rerouted into linein) you'll need the [LineIn Plugin](http://www.winamp.com/plugin/linein-plugin-v1-80/84040) for Winamp.

# Running the Mixer
## Getting started
* Start ROOT.v4p. It's better run as an ordinary patch (simply double-click) and not actually opened with "Run as Root".
* 3 windows will open after some time. One is the output which you can move wherever you like, most likely to a secondary screen. Another one is the GUI which will be explained in a section below. The third is the only actual VVVV patch window...
* In this patch window called ROOT you can adjust some basic settings: type the names of the window(s) that you would like to grab, give the output resolution do you need, perform keystoning (activate buttons with right-click), selecting the main screen (that's not working properly yet...) and some other stuff.
* Once you are finished, you may close this window with ALT+3, or you may elect to leave it in the background for later adjustments.
* Now start your program you want to grab, in our case...
* ...start XMPlay (multiple instances preferably, each can only run one AVS) then start AVS through R-Click > Options (you can and should set a keyboard shortcut for starting AVS)
* Once you open a window with a name specified in the ROOT patch it should appear as one of the inputs in the mixer.
* Note: if you specified, say, 3 entries of a window name in the ROOT patch, opening a fourth window of that kind will put that window in the 4th spot on that window name's list - i.e. it will never appear as an input, even if you close one of the initial 3 windows. You will have to close that 4th window and another one then open a new 3rd window.

Now you're good to go!


## The GUI
![GUI](https://github.com/grandchild/AVS-Mixer/raw/master/etc/GUI_simple.png)

* The four small quads in the middle are the inputs (with image-processing applied). R-click to select input channel. The coloured frames indicate how much of that input is visible in the main output.
* To the right of the inputs is the 2Mix-preview. It shows the mix between either the top or bottom row of inputs (note the white bar). Click an input to select that couple for previewing.
* The big quad below is the main preview. It shows exactly what is happening in the Main Output renderer. Use this area to move (L-click-drag) and resize (R-click-drag) the GUI.
* To the left you can see four sets of faders/buttons corresponding to the four inputs. Hover a fader/button to see what it does and inspect its current value.
* At the top there is the "AudioBox" with spectrum and bpm. Red bars on the spectrum indicate that clipping might be occurring.
* Top middle are the crossfaders, mix1+2, mix3+4 and main mix respectively. Next to these you can select the blendmode for that mix. While hovering you will see a preview of what that blendmode does in the small preview quad.
* Finally at the bottom left is the framerate display which, when hovered, will show you the input resolutions.

The ROOT.v4p patch has some more options for setup (like output resolution and keystoning)

![root](https://github.com/grandchild/AVS-Mixer/raw/master/etc/ROOTpatch_small.png)

### Interfacing the GUI with MIDI

Most parameters can be controlled with the nanoKontrol and the recommended_nanokontrol_scene.nktrl_data file loaded (the scene has to have MIDI channel 1 (not 0)):

* The four left-most transport buttons (rew, play, loop, stop) correspond to the four inputs. The faders 1-5 correspond to the parameter. Move any fader while holding one or more of the four input buttons to change parameters. The second transparent fader gives you an idea where you are on the real fader.
* The Kontrol faders 7, 8 and 9 correspond to the crossfaders (note that fader 9 is inverted to be more intuitive with the visual arrangement of the inputs in the GUI)
* The buttons next to the crossfaders allow for fast switching between 0 and 1 position of the fader.
* Some blendmodes have a secondary parameter. This parameter is set with the rotary fader above that mixer fader. These blendmodes are: Sub (change order), all Wipes (switch position), FadeOverBlack (change brightess of middle color).

## Grabbing other stuff than AVS
* VLC needs to run in GDI-output-mode and in "Minimal View" (press H)
* I tried to grab a SNES emulator and the only one that was capable of software rendering (Snes9x) - couldn't do it in Aero mode, so that's of limited use.
* VVVV render windows obviously won't work since they render in DirectX9. In future there should/will be a way to wire in VVVV's intrinsic video sources (FileStream, Textures, Cameras, etc...)
* other stuff I haven't tried yet...

## Credits
Created by (Grandchild & Hurricane) == Effekthasch

Patched by Grandchild with massive conceptual input by Hurricane

Inspired greatly by micro.D's own AVS-Mixer

Questions/bugs/feedback can be directed to our (effekhasch's) email-address at googlemail.com