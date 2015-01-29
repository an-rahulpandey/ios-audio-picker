# Description

The plugin allows you to select the song from iOS music library and copy it in your app Document directory. Then you can use the [cordova media plugin](https://github.com/apache/cordova-plugin-media) to play the song. Check the demo on how to play a song via media plugin.

### Installation

    cordova plugin add https://github.com/an-rahulpandey/ios-audio-picker.git

### Methods & Usage

- **To select the song from music library**


````
window.plugins.iOSAudioPicker.getAudio(success,error,multiple,icloud);
````

  success - will be called when the user has done selecting the songs. You can get the array of songs list using this
````javascript
    function success(data)
    {
      console.log(JSON.stringify(data));
    }
````  
 error - will be called if there are any errors in exporting or selecting the songs
````
    function error(e)
    {
      console.log(e);
    }
````  
**multiple** - a string variable which allows you the disable multiple songs selection from the user. You can either pass 'true' or 'false'
 
**icloud** - a string variable if sets 'true' will show the iCloud songs otherwise not.
````
    var multiple = 'true' // Will allow user to select multiple songs.
    or
    var multiple = 'false' // Will allow user to select only one song.
    
    var icloud = 'true' // Will show iCloud songs.
    or
    var icloud = 'false' // Will only show songs available locally on device.
````

- **To delete the song**

````
window.plugins.iOSAudioPicker.deleteSongs(success,error,option,src);
````


 option - To delete multiple files or single file. You can either pass 'true' or 'false'.
````
    var options = 'true' // Will delete multiple songs.
    or
    var options = 'false' // Will delete only one song.
````
  
  src - It depends on the value of option. If the option is true, then the src will be an array containing full path to file. Otherwise a string will single full path. The full path should not contain file://localhost or any encoded string like Value%20Space. It should start like this /var/mobile/....../file name.m4a. See demo for more information.
