import ballerina/http;
import ballerina/log;
import ballerina/sql;

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    # A resource for finding pets based on the status
    # + status - the input string status
    # + return - pets based on the status
    resource function get pets(string status) returns json|error {
        // Send a response back to the caller.
        if status is "" {

            log:printError(string `status is ${status}`);
            return error("status should not be empty!");
        }

        PetsInputItem[]|error res = getPetsBySearch(status);
        if res is error {
            log:printError(string `error occurred while invoking: ${res.message()}`);
            return res;
        } else {
            
            error? writeToDatabaseResult = addPets(res);

            if writeToDatabaseResult is sql:BatchExecuteError {
                
                log:printError(string `Error occurred while inserting to database: ${writeToDatabaseResult.message()}`);
            } 
            PetsOutputItem[] output = res.map(petItem => transform(petItem)); 
            return output.toJson();
        }
    }
}

function transform(PetsInputItem petsInputItem) returns PetsOutputItem => {
    petName: petsInputItem.name,
    photoUrls: petsInputItem.photoUrls
};

public function getPetsBySearch(string status) returns PetsInputItem[]|error {

   
    string petStoreEndPoint = "https://petstore3.swagger.io/api/v3/pet";
    http:Client petStoreClient = check new (petStoreEndPoint);
    PetsInputItem[] pets = check petStoreClient->/findByStatus(status = status);

    return pets;
}