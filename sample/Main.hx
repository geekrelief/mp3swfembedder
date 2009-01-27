import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.system.ApplicationDomain;
import flash.display.MovieClip;
import flash.media.Sound;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLRequest;
import flash.system.LoaderContext;

class Main {
    var loader:Loader;
    public static function main() {
        new Main();
    }

    public function new() {
        loader = new Loader();
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
        loader.contentLoaderInfo.addEventListener(Event.INIT, initHandler);
        var request = new URLRequest("1.swf");
        var context:LoaderContext = new LoaderContext();
        context.applicationDomain = ApplicationDomain.currentDomain;
        loader.load(request, context);
    }

    public function initHandler(e:Event):Void {
        trace("init");
        trace(e.target.content);
        trace(e.currentTarget.content);
    }

    public function completeHandler(e:Event):Void {
        trace("complete");
        trace(e.target.sameDomain);
        trace(e.target.swfVersion);
        var mc:MovieClip = e.currentTarget.content;
        trace(mc);
        var ldi:LoaderInfo = cast(e.target, LoaderInfo);
        var acid = ldi.applicationDomain.getDefinition("Mp3");
        var s = Type.createInstance(acid, []);
        s.play();
    }
}
