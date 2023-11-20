public type Category record {
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

public type TagsItem record {
    int id;
    string name;
};

public type PetsInputItem record {
    int id;
    string name;
    string[] photoUrls;
    TagsItem[] tags;
    string status;
    Category category?;
};

type PetsInput record {
    PetsInputItem[] petsInput;
};
