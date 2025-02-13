import Toybox.Lang;
import Toybox.Application.Properties;

// This class provides access to the evcc site settings
// In its current implementation, each site has setting fields
// with an index (e.g. site_0_url ). Unfortunately array settings
// do not work (Garmin bugs), so we had to revert to this solution
(:glance :background) class EvccSiteConfig {
    // Array of URLs for the evcc instances
    private var _sites = new Array<EvccSite>[0] as Array<EvccSite>;

    function getSite( i as Number ) as EvccSite { 
        return ( _sites as Array<EvccSite> )[i]; 
    }
    function getSiteCount() as Number { return _sites.size(); }

    function initialize() {
        // EvccHelper.debug("EvccSiteConfig: initialize");
        // Read sites from the configuration
        // While the Garmin SDK supports array structures for settings,
        // their implementation is extremly buggy and the consensus in the
        // developer forum is to avoid them. So we simply have 
        // a different setting for each of the five supported sites named
        // site_index.
        for( var i = 0; i < EvccConstants.MAX_SITES; i++ ) {
            var url = Properties.getValue( EvccConstants.PROPERTY_SITE_PREFIX + i + EvccConstants.PROPERTY_SITE_URL_SUFFIX ) as String;
            if( ! url.equals( "" ) ) {
                _sites.add( new EvccSite( url, i ) );
            }
        }

        /* Code for array structure setting, not used
        var storedSites = Properties.getValue( "sites" );
        if( storedSites != null && storedSites instanceof Array ) {
            _sites = storedSites;
        } */
    }
}

// This class represents the configuration of one site
(:glance :background) class EvccSite {
    private var _url as String;
    private var _user as String;
    private var _pass as String;
    private var _basicAuth = false;

    function getUrl() as String { return _url; }
    function needsBasicAuth() as Boolean { return _basicAuth; }
    function getUser() as String { return _user; }
    function getPassword() as String { return _pass; }

    function initialize( url as String, index as Number ) {
        _url = url;
        
        _user = Properties.getValue( EvccConstants.PROPERTY_SITE_PREFIX + index + EvccConstants.PROPERTY_SITE_USER_SUFFIX ) as String;
        _pass = Properties.getValue( EvccConstants.PROPERTY_SITE_PREFIX + index + EvccConstants.PROPERTY_SITE_PASS_SUFFIX ) as String;

        _basicAuth = ! _user.equals( "" );

        if( _basicAuth && _pass.equals( "" ) ) {
            throw new NoPasswordException( index );
        }
    }
}