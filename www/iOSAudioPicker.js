var exec = require('cordova/exec');

exports.getAudio = function(success, error, multiple, icloud) {
    console.log("Plugin called");
    exec(success, error, "iOSAudioPicker", "getAudio", [multiple,icloud]);
};

exports.deleteSongs = function(success, error, multiple, filepath) {
    exec(success, error, "iOSAudioPicker", "deleteSongs", [multiple,filepath]);
    
};
