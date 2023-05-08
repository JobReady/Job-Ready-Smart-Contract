// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract Job is AccessControl {
    bytes32 public constant USER_ROLE = keccak256("USER_ROLE");
    bytes32 public constant TUTOR_ROLE = keccak256("TUTOR_ROLE");

    event ProfileCreated(address indexed caller);
    event DetailsUploaded(address indexed caller);
    event DetailsUpdated(address indexed caller);

    enum Category {
        None,
        web_Development,
        blockchain_Development,
        artificial_Intelligence,
        health_Care,
        finance,
        education,
        accounting,
        engineering,
        sales
    }

    enum Level {
        junior, //can be intern
        intermediate,
        senior
    }

    struct JobExperience {
        uint32 startDate;
        uint32 endDate;
        string position;
        Category category;
        Level level;
        string JobDescription;
    }

    struct Education {
        uint32 startDate;
        uint32 endDate;
        string degree;
        string institutionName;
        string field_of_study;
    }

    struct UserInfo {
        address userAddress; //address of the user
        uint64 contact; //phone number if necessary
        string emailAddress; //not necessary though
        string userFirstName;
        string userLastName;
        string[] userSkills; //array of user skills
        // mapping(address => JobExperience) _userExperience;
        // mapping(address => Education) _userEducationalBackground;
        JobExperience _jobexperience;
        Education _education;
    }

    mapping(address => UserInfo) _userDetails;
    //mapping(address => bool) hasProfile;
    mapping(address => bool) public hasUploadedDetails;

    ///////////////ERrORS////////////////
    error notAccess();
    error UpdateDetails();
    error UploadDetails();
    error ProfileAlreadyCreated();
    error EmptyInput();
    error InvalidLevel();
    error InvalidCaterogy();
    error CreateProfile();
    error InvaliDate();

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    modifier dateCheck(uint32 _startDate, uint32 _endDate) {
        if (_startDate > _endDate) revert InvaliDate();
        _;
    }

    //function for user to create a profile on JobReady

    function createProfile(
        uint64 _contact,
        string memory _email,
        string memory _firstName,
        string memory _lastName,
        string[] memory _skills
    ) external {
        if (hasRole(USER_ROLE, msg.sender) == true)
            revert ProfileAlreadyCreated();
        if (bytes(_firstName).length == 0) revert EmptyInput();
        if (bytes(_lastName).length == 0) revert EmptyInput();
        if (_skills.length == 0) revert EmptyInput();

        UserInfo storage UI = _userDetails[msg.sender];
        UI.userAddress = msg.sender;
        UI.contact = _contact;
        UI.emailAddress = _email;
        UI.userFirstName = _firstName;
        UI.userLastName = _lastName;
        UI.userSkills = _skills;

        _grantRole(USER_ROLE, msg.sender);

        emit ProfileCreated(msg.sender);
    }

    function uploadDetails(
        Category _category,
        Level _level,
        string memory _position,
        string memory _jobDescription,
        uint32 _startDate,
        uint32 _endDate,
        string memory _degree,
        string memory _institutionName,
        string memory _fieldOfStudy,
        uint32 _startDateEdu,
        uint32 _endDateEdu
    ) external {
        if (hasRole(USER_ROLE, msg.sender) == false) revert CreateProfile();
        if (hasUploadedDetails[msg.sender] == true) revert UpdateDetails();
        if (_startDate > _endDate && _startDateEdu > _endDateEdu)
            revert InvaliDate();

        UserInfo storage UI = _userDetails[msg.sender];

        //JOB EXPERIENCE
        //Not checking for empty input here because some users might not have a job experience
        //JobExperience storage experience = _userDetails[msg.sender]
        // ._userExperience[msg.sender]; // get the job experience struct associated with the caller's address
        JobExperience memory experience;
        experience.category = _category; // update the category field

        //require that level and category is not out of board

        experience.level = _level; // update the level field
        experience.position = _position; // update the position field
        experience.JobDescription = _jobDescription; // update the job description field
        experience.startDate = _startDate; // update the start date field
        experience.endDate = _endDate; // update the end date field
        UI._jobexperience = experience; // write the job experience back to the mapping

        //EDUCATIONAL BACKGROUND
        // Education storage education = _userDetails[msg.sender]
        //     ._userEducationalBackground[msg.sender]; // get the education struct associated with the caller's address
        Education memory education;
        education.degree = _degree; // update the degree field
        education.institutionName = _institutionName; // update the institution name field
        education.field_of_study = _fieldOfStudy; // update the field of study field
        education.startDate = _startDateEdu; // update the start date field
        education.endDate = _endDateEdu; // update the end date field
        UI._education = education; // write the updated education back to the mapping

        hasUploadedDetails[msg.sender] = true;

        emit DetailsUploaded(msg.sender);
    }

    function updateContactInfo(
        uint32 _contact,
        string memory _newEmail,
        string memory _newFirstName,
        string memory _newLastName,
        string[] memory _addSkills
    ) external {
        if (hasRole(USER_ROLE, msg.sender) == false) revert CreateProfile();
        if (hasUploadedDetails[msg.sender] == false) revert UploadDetails();

        UserInfo storage UI = _userDetails[msg.sender];
        UI.userAddress = msg.sender;
        UI.contact = _contact;
        UI.emailAddress = _newEmail;
        UI.userFirstName = _newFirstName;
        UI.userLastName = _newLastName;
        UI.userSkills = _addSkills;

        emit DetailsUpdated(msg.sender);
    }

    //function for user to update their job experience
    function updateJobExperience(
        Category _category,
        Level _level,
        string memory _position,
        string memory _jobDescription,
        uint32 _startDate,
        uint32 _endDate
    ) external dateCheck(_startDate, _endDate) {
        if (hasRole(USER_ROLE, msg.sender) == false) revert CreateProfile();
        if (hasUploadedDetails[msg.sender] == false) revert UploadDetails();

        UserInfo storage UI = _userDetails[msg.sender];

        // JobExperience storage experience = _userDetails[msg.sender]
        //     ._userExperience[msg.sender]; // get the job experience struct associated with the caller's address

        JobExperience memory experience;
        experience.category = _category; // update the category field
        experience.level = _level; // update the level field
        experience.position = _position; // update the position field
        experience.JobDescription = _jobDescription; // update the job description field
        experience.startDate = _startDate; // update the start date field
        experience.endDate = _endDate; // update the end date field
        UI._jobexperience = experience; // write the updated job experience back to the mapping

        emit DetailsUpdated(msg.sender);
    }

    //function for user to update their education background
    function updateEducation(
        string memory _degree,
        string memory _institutionName,
        string memory _fieldOfStudy,
        uint32 _startDate,
        uint32 _endDate
    ) external dateCheck(_startDate, _endDate) {
        if (hasRole(USER_ROLE, msg.sender) == false) revert CreateProfile();
        if (hasUploadedDetails[msg.sender] == false) revert UploadDetails();

        UserInfo storage UI = _userDetails[msg.sender];

        // Education storage education = _userDetails[msg.sender]
        //     ._userEducationalBackground[msg.sender]; // get the education struct associated with the caller's address
        Education memory education;
        education.degree = _degree; // update the degree field
        education.institutionName = _institutionName; // update the institution name field
        education.field_of_study = _fieldOfStudy; // update the field of study field
        education.startDate = _startDate; // update the start date field
        education.endDate = _endDate; // update the end date field
        UI._education = education;

        emit DetailsUpdated(msg.sender);
    }

    // function to check if a user has created a profile on the JobReady App
    function profileExists(address userAddr) external view returns (bool) {
        return hasRole(USER_ROLE, userAddr);
    }

    function getUserInfo(
        address userAddr
    ) external view returns (UserInfo memory) {
        if (hasRole(USER_ROLE, msg.sender) == false) revert CreateProfile();
        require(
            msg.sender == userAddr ||
                hasRole(DEFAULT_ADMIN_ROLE, msg.sender) == true,
            "no access"
        );
        if (hasUploadedDetails[msg.sender] == false) revert UpdateDetails();
        UserInfo storage UI = _userDetails[userAddr];
        return UI;
    }

  
}
