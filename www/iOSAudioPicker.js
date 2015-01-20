var exec = require('cordova/exec');

exports.getAudio = function(success, error, args) {
    console.log("Plugin called");
    exec(success, error, "iOSAudioPicker", "getAudio", [args]);
};

exports.deleteSongs = function(success, error, multiple, filepath) {
    exec(success, error, "iOSAudioPicker", "deleteSongs", [multiple,filepath]);
    
};