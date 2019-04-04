var oscarApp = angular.module('oscarTablet',
    ['ui.router', 'ngResource', 'ui.bootstrap', 'demographicServices', 'securityServices', 'personaServices', 'formServices']);


oscarApp.config(['$stateProvider', '$urlRouterProvider',function($stateProvider, $urlRouterProvider) {
    //
    // For any unmatched url, redirect to /state1
    $urlRouterProvider.otherwise("/search");
    //
    // Now set up the states
    $stateProvider
        .state('search', {
            url: '/search',
            templateUrl: 'patientSearch/patientSearch.html',
            controller: 'PatientSearchCtrl'
        })
}]);
