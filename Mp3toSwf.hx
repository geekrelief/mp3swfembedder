import neko.Sys;
import neko.Lib;
import neko.io.File;
import neko.FileSystem;

import haxe.xml.Fast;

class Mp3toSwf {
    public static function main(){
        var input_mp3 = "";
        var output_swf = "";
        if(Sys.args().length == 1){
            input_mp3 = Sys.args()[0];
            if(input_mp3.split(".").pop().toLowerCase() != "mp3") {
                Lib.println("mp3_input doesn't have an mp3 extension"); 
                return;
            }
            output_swf = input_mp3.split(".").shift()+".swf";
        } else if(Sys.args().length == 2) {
            input_mp3 = Sys.args()[0];
            output_swf = Sys.args()[1];
        } else {
            Lib.println("mp3toswf embedder - Copyright 2009 - Don-Duong Quach\nUsage: embed {mp3_input} [output_swf]");            
            return;
        }
        
        var sound_template = '<?xml version="1.0" ?> <movie version="10" framerate="10" height="300" width="400"> <library> <clip id="Mp3" import="#mp3#"/> </library> <frame> <place id="Mp3"/> </frame> </movie>';
        var mp3_template ='<?xml version="1.0"?> <swf version="10" compressed="1"> <Header framerate="24" frames="1"> <size> <Rectangle left="0" right="11000" top="0" bottom="8000"/> </size> <tags> <FileAttributes hasMetaData="0" allowABC="1" suppressCrossDomainCaching="0" swfRelativeURLs="0" useNetwork="0"/> <SetBackgroundColor> <color> <Color red="255" green="255" blue="255"/> </color> </SetBackgroundColor> <UnknownTag id="0x56"> <data>AQBTY2VuZSAxAAA=</data> </UnknownTag> <SoundStreamHead2 playbackRate="3" playbackSize="1" playbackStereo="1" compression="0" soundRate="0" soundSize="0" soundStereo="0" sampleSize="0"/> <DoABCDefine flags="1" name=""> <actions> <Action3 minorVersion="16" majorVersion="46"> <constants> <Constants> <ints/> <uints/> <doubles/> <strings> <String2 value=""/> <String2 value="Mp3"/> <String2 value="flash.media"/> <String2 value="Sound"/> <String2 value="Object"/> <String2 value="flash.events"/> <String2 value="EventDispatcher"/> </strings> <namespaces> <PackageNamespace index="1"/> <PackageNamespace index="3"/> <ProtectedNamespace index="2"/> <PackageNamespace index="6"/> </namespaces> <namespaceSets/> <multinames> <QName namespaceIndex="1" nameIndex="2"/> <QName namespaceIndex="2" nameIndex="4"/> <QName namespaceIndex="1" nameIndex="5"/> <QName namespaceIndex="4" nameIndex="7"/> </multinames> </Constants> </constants> <methods>'

              +'<MethodInfo retType="0" nameIndex="0" hasParamNames="0" setSDXNs="0" isExplicit="0" ignoreRest="0" hasOptional="0" needRest="0" needActivation="0" needArguments="0"> <paramTypes/> </MethodInfo> <MethodInfo retType="0" nameIndex="0" hasParamNames="0" setSDXNs="0" isExplicit="0" ignoreRest="0" hasOptional="0" needRest="0" needActivation="0" needArguments="0"> <paramTypes/> </MethodInfo> <MethodInfo retType="0" nameIndex="0" hasParamNames="0" setSDXNs="0" isExplicit="0" ignoreRest="0" hasOptional="0" needRest="0" needActivation="0" needArguments="0"> <paramTypes/> </MethodInfo> </methods> <metadata/> <instances> <InstanceInfo nameIndex="1" superIndex="2" hasProtectedNS="1" interface="0" final="0" sealed="0" protectedNS="3" iInitIndex="1"> <interfaces/> <traits/> </InstanceInfo> </instances> <classes> <ClassInfo cInitIndex="0"> <traits/> </ClassInfo> </classes> <scripts> <ScriptInfo initIndex="2"> <traits> <TraitInfo nameIndex="1" override="0" final="0"> <trait> <Class slotID="1" classInfo="0"/> </trait> </TraitInfo> </traits> </ScriptInfo> </scripts> <methodBodies> <MethodBody methodInfo="0" maxStack="1" maxRegs="1" scopeDepth="5" maxScope="6" exceptionCount="0"> <code> <OpGetLocal0/> <OpPushScope/> <OpReturnVoid/> </code> <exceptions/> <traits/> </MethodBody> <MethodBody methodInfo="1" maxStack="1" maxRegs="1" scopeDepth="6" maxScope="7" exceptionCount="0"> <code> <OpGetLocal0/> <OpPushScope/> <OpGetLocal0/> <OpConstructSuper argc="0"/> <OpReturnVoid/>'

               +'</code> <exceptions/> <traits/> </MethodBody> <MethodBody methodInfo="2" maxStack="2" maxRegs="1" scopeDepth="1" maxScope="5" exceptionCount="0"> <code> <OpGetLocal0/> <OpPushScope/> <OpGetScopeObject scopeIndex="0"/> <OpGetLex name="3"/> <OpPushScope/> <OpGetLex name="4"/> <OpPushScope/> <OpGetLex name="2"/> <OpPushScope/> <OpGetLex name="2"/> <OpNewClass classIndex="0"/> <OpPopScope/> <OpPopScope/> <OpPopScope/> <OpInitProperty name="1"/> <OpReturnVoid/> </code> <exceptions/> <traits/> </MethodBody> </methodBodies> </Action3> </actions> </DoABCDefine> <SymbolClass> <symbols> <Symbol objectID="1" name="Mp3"/> </symbols> </SymbolClass> <ShowFrame/> <End/> </tags> </Header> </swf>';

        // open the sound_template.xml and change the import attribute #mp3#
//        var stemp = File.getContent("sound_template.xml");
//        var doc = Xml.parse(stemp);
        var doc = Xml.parse(sound_template);
        var clip = doc.firstElement().firstElement().firstElement();
        clip.set("import", input_mp3);


        // from the template create a swf
        var mtemp = File.write("temp_mp3embed.xml", false);
        mtemp.writeString(doc.toString());
        mtemp.close();

        Sys.command("swfmill", ["simple", "temp_mp3embed.xml", "temp_mp3embed.swf"]);

        // get the xml from the swf to get the DefineSound node
        Sys.command("swfmill", ["swf2xml", "temp_mp3embed.swf", "temp_mp3embed_swfmill.xml"]);

        var mDoc =  Xml.parse(File.getContent("temp_mp3embed_swfmill.xml"));
        var headerIter = mDoc.firstElement().firstElement().elements();
        headerIter.next(); // size
        var tagsIter = headerIter.next().elements();
        tagsIter.next(); // FileAttributes
        var defs = tagsIter.next();

        // write the data into the Sound instance template
        //var oDoc = Xml.parse(File.getContent("mp3_template.xml"));
        var oDoc = Xml.parse(mp3_template);
        headerIter = oDoc.firstElement().firstElement().elements();
        headerIter.next();
        var otags = headerIter.next(); // tags
        otags.insertChild(defs, 8);

        var oxmlfile = File.write("temp_mp3_final.xml", false);
        oxmlfile.writeString(oDoc.toString());
        oxmlfile.close();

        // build the mp3 Sound embedded swf
        Sys.command("swfmill", ["xml2swf", "temp_mp3_final.xml", output_swf]);
        Lib.println("created: "+output_swf);
        FileSystem.deleteFile("temp_mp3embed.xml");
        FileSystem.deleteFile("temp_mp3embed.swf");
        FileSystem.deleteFile("temp_mp3embed_swfmill.xml");
        FileSystem.deleteFile("temp_mp3_final.xml");
    }
}
