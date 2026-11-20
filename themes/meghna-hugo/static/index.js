var AptiotCmdbApi = require('aptiot_cmdb_api');
var api = new AptiotCmdbApi.DefaultApi()

const getLastItem = thePath => thePath.substring(thePath.lastIndexOf('/') + 1)
let path = window.location.pathname

// remove trailing slash
if(path.lastIndexOf('/') == path.length - 1) {
    path = path.substring(0, path.length - 1)
}

// code of device
let code = getLastItem(path)
let params = new URLSearchParams(window.location.search);
let verification = params.get("v");
console.log('Path is ' + path)
console.log('Last path item is ' + code)
console.log('Verification code is ' + verification)

var callback = function(error, data, response) {
    if (error) {
        console.error(error);
    } else {
        console.log('API called successfully. Returned records: ' + data["meta"]["total"]);

        document.getElementById("code").innerHTML = data["data"][0]["Code"] ?? 'N/A'
        document.getElementById("installationDate").innerHTML += data["data"][0]["InstallationDate"] ?? 'N/A'
        document.getElementById("acceptanceDate").innerHTML += data["data"][0]["AcceptanceDate"] ?? 'N/A'
        document.getElementById("brandDescription").innerHTML += data["data"][0]["_Brand_description"] ?? 'N/A'
        document.getElementById("condition").innerHTML += data["data"][0]["Condition"] ?? 'N/A'
        document.getElementById("buildingDescription").innerHTML += data["data"][0]["_Building_description"] ?? 'N/A'
        document.getElementById("floor").innerHTML += data["data"][0]["_Floor_description"] ?? 'N/A'
        document.getElementById("model").innerHTML += data["data"][0]["ModelData"] ?? 'N/A'
        document.getElementById("name").innerHTML += data["data"][0]["Name"] ?? 'N/A'
        document.getElementById("notes").innerHTML += data["data"][0]["Notes"] ?? 'N/A'
        document.getElementById("room").innerHTML += data["data"][0]["_Room_description"] ?? 'N/A'
        document.getElementById("serialNumber").innerHTML += data["data"][0]["SerialNumber"] ?? 'N/A'
        document.getElementById("serviceStatus").innerHTML += data["data"][0]["ServiceStatus"] ?? 'N/A'
        document.getElementById("type").innerHTML += data["data"][0]["Type"] ?? 'N/A'
        document.getElementById("unitDescription").innerHTML += data["data"][0]["_Unit_description"] ?? 'N/A'
        document.getElementById("voltage").innerHTML += data["data"][0]["Voltage"] ?? 'N/A'
        document.getElementById("warrantyEnd").innerHTML += data["data"][0]["WarrantyEnd"] ?? 'N/A'
    }
};
api.readManyElectricalPanels(code, verification, callback);
