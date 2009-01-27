import neko.Sys;
import neko.Lib;
import neko.io.File;

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

        // open the sound_template.xml and change the import attribute #mp3#
        var stemp = File.getContent("sound_template.xml");
        var doc = Xml.parse(stemp);
        var clip = doc.firstElement().firstElement().firstElement();
        clip.set("import", input_mp3);


        // from the template create a swf
        var mtemp = File.write("mp3embed.xml", false);
        mtemp.writeString(doc.toString());
        mtemp.close();

        Sys.command("swfmill", ["simple", "mp3embed.xml", "mp3embed.swf"]);

        // get the xml from the swf to get the DefineSound node
        Sys.command("swfmill", ["swf2xml", "mp3embed.swf", "mp3embed_swfmill.xml"]);

        var mDoc =  Xml.parse(File.getContent("mp3embed_swfmill.xml"));
        var headerIter = mDoc.firstElement().firstElement().elements();
        headerIter.next(); // size
        var tagsIter = headerIter.next().elements();
        tagsIter.next(); // FileAttributes
        var defs = tagsIter.next();

        // write the data into the Sound instance template
        var oDoc = Xml.parse(File.getContent("mp3_template.xml"));
        headerIter = oDoc.firstElement().firstElement().elements();
        headerIter.next();
        var otags = headerIter.next(); // tags
        otags.insertChild(defs, 8);

        var oxmlfile = File.write("mp3_final.xml", false);
        oxmlfile.writeString(oDoc.toString());
        oxmlfile.close();

        // build the mp3 Sound embedded swf
        Sys.command("swfmill", ["xml2swf", "mp3_final.xml", output_swf]);
        Lib.println("created: "+output_swf);
    }
}
