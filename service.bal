import ballerina/http;
import ballerina/log;

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    # A resource for generating greetings
    # + status - the input string status
    # + return - pet store name with hello message or error
    resource function get pets(string status) returns json|error {
        // Send a response back to the caller.
        if status is "" {
            return error("status should not be empty!");
        }
        log:printInfo(string `status is ` + status);

        PetsInputItem[]|error res = getPetsBySearch(status);
        if res is error {
            log:printError("error occured while invoking");
            return {"Error":1};
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

    if status is "" {
        return error("status cannot be empty");
    } else {

        string petStoreEndPoint = "https://petstore3.swagger.io/api/v3/pet";
        http:Client petStoreClient = check new (petStoreEndPoint);
        PetsInputItem[] pets = check petStoreClient->/findByStatus(status = status);

        return pets;
    }
}
