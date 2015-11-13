package me.rahul.plugins;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.content.ContentResolver;
import android.media.MediaMetadataRetriever;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Arrays;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class AudioPicker extends CordovaPlugin {

    private static final int REQUEST_PICK_AUDIO = 1;

    private static final List<String> SUPPORTED_EXTENSION = Arrays.asList("mp3", "ogg", "wav", "m4a");

    private CallbackContext mCallbackContext;

    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        mCallbackContext = callbackContext;

        if (action.equals("getAudio")) {
            Intent intent = new Intent();
            intent.setType("audio/*");
            intent.setAction(Intent.ACTION_GET_CONTENT);
            cordova.startActivityForResult(this, Intent.createChooser(intent, "Select song to mix"), REQUEST_PICK_AUDIO);
            return true;
        } else if (action.equals("deleteSongs")) {
            return true;
        }
        else { // Unrecognized action.
            return false;
        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent intent) {
        super.onActivityResult(requestCode, resultCode, intent);
        if (mCallbackContext != null) {
            if (REQUEST_PICK_AUDIO == requestCode) {
                if (Activity.RESULT_OK == resultCode) {
                    Uri uri = intent.getData();
                    String extension = getUriExtension(uri);
                    if (extension != null) {
                        String destPath = cordova.getActivity().getFilesDir() + "/track." + extension;
                        if (copyUriToPath(uri, destPath)) {
                            JSONObject mediaInfo = getMediaInfoFromPath(destPath);
                            mCallbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, mediaInfo));
                        } else {
                            mCallbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, "Error copying file"));
                        }
                    } else {
                        mCallbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, "Invalid file"));
                    }
                } else {
                    mCallbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, "Selection canceld"));
                }
            }
        }
    }

    private String getUriExtension(Uri uri) {
        String extension = null;

        ContentResolver cR = cordova.getActivity().getContentResolver();
        String type = cR.getType(uri);
        if (type != null) {
            if (type.equals("audio/mpeg")) {
                extension = "mp3";
            } else if (type.equals("audio/mp4")) {
                extension = "m4a";
            } else if (type.equals("audio/x-wav")) {
                extension = "wav";
            } else if (type.equals("audio/ogg")) {
                extension = "ogg";
            }
        } else {
            String filePath = uri.toString();
            if (filePath.startsWith("file://")) {
                int lastIndex = filePath.lastIndexOf(".");
                if ((lastIndex > -1) && (lastIndex != filePath.length())) {
                    extension = filePath.substring(lastIndex + 1).toLowerCase();
                }
            }
        }

        if (SUPPORTED_EXTENSION.contains(extension)) {
            return extension;
        } else {
            return null;
        }
    }

    private Boolean copyUriToPath(Uri uri, String destPath) {
        File dstFile = new File(destPath);
        if (!dstFile.exists()) {
            try {
                Boolean retVal = dstFile.createNewFile();
            } catch (IOException e) {
                e.printStackTrace();
                return false;
            }
        }
        try {
            InputStream is = cordova.getActivity().getContentResolver().openInputStream(uri);
            OutputStream os = new FileOutputStream(dstFile);

            byte[] buf = new byte[1024];
            int len;
            while ((len = is.read(buf)) > 0) {
                os.write(buf, 0, len);
            }
            is.close();
            os.close();
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
        return true;
    }

    private JSONObject getMediaInfoFromPath(String path) {
        JSONObject mediaInfo = new JSONObject();

        String artist = "No Artist";
        String album = "No Album";
        String title = "No Title";
        int duration = 0;
        String image = "No Image";

        MediaMetadataRetriever metaRetriver = new MediaMetadataRetriever();
        metaRetriver.setDataSource(path);

        try {
            artist = metaRetriver.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ARTIST);
            if (artist == null) artist = "No Artist";
            album = metaRetriver.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ALBUM);
            if (album == null) album = "No Album";
            title = metaRetriver.extractMetadata(MediaMetadataRetriever.METADATA_KEY_TITLE);
            if (title == null) title = "No Title";
            String dur = metaRetriver.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION);
            if (dur == null) {
                duration = 0;
            } else {
                duration = Integer.valueOf(dur);
            }
            byte [] art = metaRetriver.getEmbeddedPicture();
            if (art == null) {
                image = "No Image";
            } else {
                image = Base64.encodeBytes(art);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        try {
            mediaInfo.put("artist", artist);
            mediaInfo.put("albumTitle", album);
            mediaInfo.put("title", title);
            mediaInfo.put("duration", duration);
            mediaInfo.put("exportedurl", "file://" + path);
            mediaInfo.put("image", image);
        } catch (JSONException e) {
            e.printStackTrace();
        }

        return mediaInfo;
    }
}
