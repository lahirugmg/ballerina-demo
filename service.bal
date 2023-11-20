import ballerina/http;
import ballerina/log;

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    # A resource for finding pets based on the status
    # + status - the input string status
    # + return - pets based on the status
    resource function get pets(string status) returns json|error {
        // Send a response back to the caller.
        if status is "" {

            log:printError(string `status is ` + status);
            return error("status should not be empty!");
        }

        PetsInputItem[]|error res = getPetsBySearch(status);
        if res is error {
            log:printError("error occured while invoking: " + res.message());
            return res;
        } else {
            

            PetsOutputItem[] output = res.map(petItem => transform(petItem)); 
            return output.toJson();
        }
    }
}

type Category record {
    int id;
    string name;
};

type PetsOutputItem record {
    string petName;
    string[] photoUrls?;
};

type PetsOutput record {
    PetsOutputItem[] petsOutput;
};

type TagsItem record {
    int id;
    string name;
};

type PetsInputItem record {
    int id;
    string name;
    (string[]) photoUrls;
    (TagsItem[]|anydata[]) tags;
    string status;
    Category category?;
};

type PetsInput record {
    PetsInputItem[] petsInput;
};

function transform(PetsInputItem petsInputItem) returns PetsOutputItem => {
    petName: petsInputItem.name,
    photoUrls: petsInputItem.photoUrls
};

public function getPetsBySearch(string status) returns PetsInputItem[]|error {

//    string petStoreEndPoint = "https://petstore3.swagger.io/api/v3/pet";
    string petStoreEndPoint = "https://run.mocky.io/v3/8efa2487-ebd6-4faf-85d3-1aa2c886fe37";
    http:Client petStoreClient = check new (petStoreEndPoint);
    PetsInputItem[] pets = check petStoreClient->/findByStatus(status = status);

    return pets;
}
