import ballerina/constraint;
import ballerina/http;
import ballerina/log;
import ballerina/sql;

// Validate status if not empty
@constraint:String {
    minLength: 1
}
type Status string;

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    # A resource for finding pets based on the status
    # + status - the input string status
    # + return - pets based on the status
    resource function get pets(Status status) returns PetsOutputItem[]|error {
        // Send a response back to the caller.
        PetsInputItem[]|error res = getPetsBySearch(status);
        if res is error {
            log:printError(string `error occurred while invoking: ${res.message()}`);
            return res;
        }

        error? writeToDatabaseResult = addPets(res);

        if writeToDatabaseResult is sql:BatchExecuteError {

            log:printError(string `Error occurred while inserting to database: ${writeToDatabaseResult.message()}`);
        }
        PetsOutputItem[] output = res.map(petItem => transform(petItem));
        return output;
    }
}

function transform(PetsInputItem petsInputItem) returns PetsOutputItem => {
    petName: petsInputItem.name,
    photoUrls: petsInputItem.photoUrls
};

public function getPetsBySearch(string status) returns PetsInputItem[]|error {

    string petStoreEndPoint = "https://run.mocky.io/v3/8efa2487-ebd6-4faf-85d3-1aa2c886fe37";
    http:Client petStoreClient = check new (petStoreEndPoint);
    PetsInputItem[] pets = check petStoreClient->/findByStatus(status = status);

    return pets;
}
