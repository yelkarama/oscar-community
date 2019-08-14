jQuery(document).ready(function(){
    jQuery("#checkAllLink").hide();
});

function addProviderToSite(providers, siteId, provider) {
    if (providers.find( p => p.providerNo === provider.providerNo ) == null) {
        providers.push(provider);
    }

    let site = sites.find( site => site.id === siteId );
    if (site != null) {
        site.providers.push(provider);
    }
}

function buildProviderList(providers, siteId){
    let assignedToEl = jQuery('#assignedTo');
    assignedToEl.empty();
    let theProviders = [];
    if (siteId === "all") {
        theProviders = providers;
        assignedToEl.append(jQuery("<option></option>")
            .text("All Providers")
            .attr("value", "all")
        );
    } else {
        let site = sites.find( site => site.id === siteId );
        theProviders = site.providers;
    }
    
    theProviders.forEach(function(p) {
       assignedToEl.append(jQuery("<option></option>")
           .text(p.name)
           .attr("value", p.providerNo)
        );
    });
}

function changeSite(sel, providers) {
    buildProviderList(providers, sel.value)
}