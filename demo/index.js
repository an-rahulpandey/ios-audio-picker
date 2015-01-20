/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
var src;
var srcarray = [];

function plsuccess(data){
    //console.log("Data = "+JSON.stringify(data));
    src = data[0].exportedurl;
    src = src.replace("file://localhost/","/");
    src = decodeURI(src);
    document.getElementById('playbtn').disabled = false;
    document.getElementById('delbtn').disabled = false;
    document.getElementById('delMbtn').disabled = false;
    console.log(src);
    var slen = data.length;
    console.log(slen);
    for(var i=0;i<slen;i++)
    {
        var fileurl = data[i].exportedurl;
        fileurl = fileurl.replace("file:///","/");
        fileurl = decodeURI(fileurl);
        srcarray.push(fileurl);
    }
}
function playsong()
{
    console.log("Inisde Playsong");
    my_media = new Media(src, onSuccess, onError);
    
    // Play audio
    my_media.play();
}

function delsong()
{
    window.plugins.iOSAudioPicker.deleteSongs(delSuccess,delError,'false',src);
}

function delmsong()
{
    window.plugins.iOSAudioPicker.deleteSongs(delSuccess,delError,'true',srcarray);
}

function delSuccess(a)
{
    console.log(JSON.stringify(a));
}
function delError(e)
{
    console.log(JSON.stringify(e));
}

// onSuccess Callback
//
function onSuccess() {
    console.log("playAudio():Audio Success");
}

// onError Callback
//
function onError(error) {
    alert('code: '    + error.code    + '\n' +
          'message: ' + error.message + '\n');
}
