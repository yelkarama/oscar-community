oscarApp.controller('PatientSearchCtrl', function ($scope, $timeout, $resource, securityService, $http, demographicService, $state, formService) {
    $scope.patient = {
        firstName: '',
        lastName: '',
        gender: '',
        dob: '',
        hin: ''
    };

    $scope.finished = false;
    $scope.isAuthorized = false;
    
    let eformIntakeId = "";
    
    securityService.hasRights({items: [{objectName: '_eform', privilege: 'w'}, {objectName: '_demographic', privilege: 'r'}]}).then(function(result){
        if(result.content != null && result.content.length === 2) {
            $scope.eformWriteAccess = result.content[0];
            $scope.demographicReadAccess = result.content[1];
            $scope.isAuthorized = $scope.eformWriteAccess && $scope.demographicReadAccess;

            if($scope.isAuthorized) {
                formService.getIntakeEformId().then(function(response) {
                    eformIntakeId = response.intakeEformId;
                });
            } else {
                alert("Patient intake was not set up completely. Please contact the clinic for additional support.");
            }
        } else {
            alert('Could not load rights');
        }
    },function(reason){
        alert(reason);
    });

    $scope.matchDemographic = function() {
        let errors = validateInput();
        if (errors.length === 0) {
            demographicService.matchDemographic($scope.patient).then(function (response) {
                if (response.data.code === "A") {
                    openForm(response.data.demographicNo);
                } else {
                    alert(response.data.message);
                }
            }, function (response) {
                alert(response);
            });
        } else {
            alert(errors.join("\n"));
        }
    };

    function openForm(demographicNo) {
        let url = '/oscar/eform/efmformadd_data.jsp?fid=' + eformIntakeId + '&demographic_no=' + demographicNo;

        let rnd = Math.round(Math.random() * 1000);
        win = "win" + rnd;

        let width = window.innerWidth;
        let height = window.innerHeight;
        let features = "scrollbars=yes, location=no, width=" + width + ", height=" + height + "\"";
        window.open(url, win, features, "");
        
        $scope.finished = true;
    }
    
    function validateInput() {
        let errors = [];
        if ($scope.patient.firstName.length === 0) {
            errors.push("You must enter a first name");
        }
        if ($scope.patient.lastName.length === 0) {
            errors.push("You must enter a last name");
        }
        if ($scope.patient.gender.length === 0) {
            errors.push("You must select a gender");
        }
        if ($scope.patient.dob === undefined || $scope.patient.dob.length === 0) {
            errors.push("You must enter a valid date of birth in the format of YYYY-MM-DD");
        }
        if (!$scope.patient.hin.match(/^\d{10}$/)) {
            errors.push("You must enter a 10 digit HIN without the version code");
        }
        return errors;
    }
});

function pad0(n) {
    if (n.length>1) return n;
    else return "0"+n;
}