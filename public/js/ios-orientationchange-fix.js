/*




NOTE!!!!

The most updated version of this code is here:

https://github.com/scottjehl/iOS-Orientationchange-Fix




 A fix for the dreaded iOS orientationchange zoom bug http://adactio.com/journal/5088/. Seems to work!
 Authored by @scottjehl. Props to @wilto for addressing a tilt caveat.
 MIT License.

FOR LATEST, SEE https://github.com/scottjehl/iOS-Orientationchange-Fix
*/

(function(w){
    var doc = w.document;

    if( !doc.querySelectorAll ){ return; }

    var meta = doc.querySelectorAll( "meta[name=viewport]" )[ 0 ],
        initialContent = meta && meta.getAttribute( "content" ),
        disabledZoom = initialContent + ", maximum-scale=1.0",
        enabledZoom = initialContent + ", maximum-scale=10.0",
        enabled = true,
        orientation = w.orientation,
        rotation = 0;

    if( !meta ){ return; }

    function restoreZoom(){
        meta.setAttribute( "content", enabledZoom );
        document.body.innerHTML = document.body.innerHTML;
        enabled = true;
    }

    function disableZoom(){
        meta.setAttribute( "content", disabledZoom );
        enabled = false;
    }

    function checkTilt( e ){
        orientation = Math.abs( w.orientation );
        rotation = Math.abs( e.gamma );

        if( rotation > 8 && orientation === 0 ){
            if( enabled ){
                disableZoom();
            }   
        }
        else {
            if( !enabled ){
                restoreZoom();
            }
        }

    }

    w.addEventListener( "orientationchange", restoreZoom, false );
    w.addEventListener( "deviceorientation", checkTilt, false );

})( this );