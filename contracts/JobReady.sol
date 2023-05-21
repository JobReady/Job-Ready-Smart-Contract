// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/AccessControl.sol";

interface IJobReadyNFT {
    function awardUser(address user) external returns (uint256);
}

contract Job is AccessControl {
    event ProfileCreated(address indexed caller);
    event DetailsUploaded(address indexed caller);
    event DetailsUpdated(address indexed caller);

    bytes32 public constant USER_ROLE = keccak256("USER_ROLE");
    bytes32 public constant TUTOR_ROLE = keccak256("TUTOR_ROLE");

    enum Category {
        none,
        PMKT, // Product Manager Knowledge Test
        SDKT, //SoftwareDeveloperKnowledgeTest
        DA, //Data Analysis
        UIUX, //UI/UX Designer
        CE, //Cybersecurity Engineering
        AMR, // 3D Animation and Mixed reality
        BE // Blockchain engineering
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

    modifier dateCheck(uint32 _startDate, uint32 _endDate) {
        if (_startDate > _endDate) revert InvaliDate();
        _;
    }

    ///////////////ERRORS////////////////
    error notAccess();
    error UpdateDetails();
    error UploadDetails();
    error ProfileAlreadyCreated();
    error EmptyInput();
    error InvalidLevel();
    error InvalidCaterogy();
    error CreateProfile();
    error InvaliDate();

    IJobReadyNFT nftAddr; //address of the NFT contract

    constructor(IJobReadyNFT _nftAddr) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        nftAddr = _nftAddr;
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
        JobExperience memory experience;
        experience.category = _category; // update the category field

        experience.level = _level; // update the level field
        experience.position = _position; // update the position field
        experience.JobDescription = _jobDescription; // update the job description field
        experience.startDate = _startDate; // update the start date field
        experience.endDate = _endDate; // update the end date field
        UI._jobexperience = experience; // write the job experience back to the mapping

        //EDUCATIONAL BACKGROUND
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

    /////////////SKILL TEST/////////////
    event FeedbackProvided();

    /**
     * @dev struct Question is defined to represent a single question.
     * It contains the question text(description), an array of options, and the index of the correct option
     */
    struct Question {
        string questionText;
        string[] options;
        uint256 correctOptionIndex;
    }

    mapping(uint256 => mapping(uint256 => Question)) questions; //Maps category and question numbers to their corresponding questions.
    mapping(uint256 => mapping(uint256 => bool)) questionUploaded; //Tracks whether a question has been uploaded or not
    mapping(uint256 => uint256) totalQuestions; //Keeps track of the total number of questions in each category
    mapping(address => mapping(uint256 => mapping(uint256 => bool))) questionAnswered; //Tracks whether a user has answered a specific question
    mapping(address => mapping(uint256 => uint256)) rightPicked; //Keeps track of the number of questions answered correctly by a user
    mapping(address => mapping(uint256 => string)) feedback;

    //ERRORS
    error QuestionNumAlreadyFilled();
    error QuestionMustHaveAtLeast2Options();
    error CorrectOptionIDMustBeLessThanOptions();
    error NotTutor();
    error NotARegisteredUser();
    error QuestionAlreadyAnswered();
    error ChosenOptionIDMustBeLessThanOptions();
    error AddressZero();
    error FeedBackCannotBeEmpty();
    error AnswerALLQuestion();

    /**
     *
     * @param _questionType: The type/category of the question
     * @param _questionNumber: The number of the question within the category
     * @param _questionText: question desciption
     * @param _options: question options
     * @param _correctOptionIndex: question correctoption index
     */
    function addQuestion(
        uint256 _questionType,
        uint256 _questionNumber,
        string memory _questionText,
        string[] memory _options,
        uint256 _correctOptionIndex
    ) external {
        if (hasRole(TUTOR_ROLE, msg.sender) == false) revert NotTutor();
        if (questionUploaded[_questionType][_questionNumber] == true) {
            revert QuestionNumAlreadyFilled();
        }

        if (_options.length < 2) {
            revert QuestionMustHaveAtLeast2Options();
        }

        if (_correctOptionIndex > _options.length) {
            revert CorrectOptionIDMustBeLessThanOptions();
        }

        questions[_questionType][_questionNumber] = Question(
            _questionText,
            _options,
            _correctOptionIndex
        );

        questionUploaded[_questionType][_questionNumber] = true;
        totalQuestions[_questionType] += 1;
    }

    /**
     *
     * @param _questionType: The type/category of the question
     * @param _questionNumber: The number of the question within the category
     * @param _correctOptionIndex: question correctoption index
     */
    function changeCorrectOptionIndex(
        uint256 _questionType,
        uint256 _questionNumber,
        uint256 _correctOptionIndex
    ) external {
        if (hasRole(TUTOR_ROLE, msg.sender) == false) revert NotTutor();
        questions[_questionType][_questionNumber]
            .correctOptionIndex = _correctOptionIndex;
    }

    function answerQuestion(
        uint256 _questionType,
        uint256 _questionNumber,
        uint256 _chosenOptionIndex
    ) external returns (bool) {
        if (hasRole(USER_ROLE, msg.sender) == false)
            revert NotARegisteredUser();

        if (
            questionAnswered[msg.sender][_questionType][_questionNumber] == true
        ) {
            revert QuestionAlreadyAnswered();
        }
        if (
            _chosenOptionIndex >
            questions[_questionType][_questionNumber].options.length
        ) {
            revert ChosenOptionIDMustBeLessThanOptions();
        }

        questionAnswered[msg.sender][_questionType][_questionNumber] = true;

        if (
            _chosenOptionIndex ==
            questions[_questionType][_questionNumber].correctOptionIndex
        ) {
            rightPicked[msg.sender][_questionType] += 1;
            nftAddr.awardUser(msg.sender);
            return true;
        } else {
            return false;
        }
    }

    /**
     * dev: function for a tutor to reset a particular question for participant
     */
    function resetQuestion(
        address _participantAddress,
        uint256 _questionType
    ) external {
        if (hasRole(TUTOR_ROLE, msg.sender) == false) revert NotTutor();
        if (_participantAddress == address(0)) revert AddressZero();

        uint256 total = totalQuestions[_questionType];

        for (
            uint256 _questionNumber;
            _questionNumber < total;
            _questionNumber++
        ) {
            questionAnswered[_participantAddress][_questionType][
                _questionNumber
            ] = false;
        }

        feedback[_participantAddress][_questionType] = "No question answered";
    }

    /**
     *
     * @dev function to get all Question details in a category
     */
    function getAllQuestions(
        uint256 _questionType
    ) external view returns (Question[] memory) {
        if (hasRole(TUTOR_ROLE, msg.sender) == false) revert NotTutor();

        uint256 total = totalQuestions[_questionType];

        Question[] memory allQuestion = new Question[](total);

        for (uint256 i; i < total; i++) {
            allQuestion[i] = questions[_questionType][i + 1];
        }

        return allQuestion;
    }

    function getAllQuestionsForAUser(
        uint256 _questionType
    ) external view returns (string[] memory, string[][] memory) {
        uint256 total = totalQuestions[_questionType];

        string[] memory allQuestion = new string[](total);
        string[][] memory option = new string[][](total);

        for (uint256 i; i < total; i++) {
            allQuestion[i] = questions[_questionType][i + 1].questionText;
            option[i] = questions[_questionType][i + 1].options;
        }

        return (allQuestion, option);
    }

    function getFullQuestion(
        uint256 _questionType,
        uint256 _questionNumber
    ) external view returns (string memory, string[] memory) {
        return (
            getQuestion(_questionType, _questionNumber),
            getOptions(_questionType, _questionNumber)
        );
    }

    function getNextQuestionNumber(
        uint256 _questionType
    ) external view returns (uint256) {
        return totalQuestions[_questionType] + 1;
    }

    /**
     * @dev function to get a particular question details
     */
    function getQuestionDetails(
        uint256 _questionType,
        uint256 _questionNumber
    ) external view returns (Question memory) {
        if (hasRole(TUTOR_ROLE, msg.sender) == false) revert NotTutor();
        return questions[_questionType][_questionNumber];
    }

    /**
     * @dev function to get question description
     */
    function getQuestion(
        uint256 _questionType,
        uint256 _questionNumber
    ) public view returns (string memory) {
        return questions[_questionType][_questionNumber].questionText;
    }

    function getOptions(
        uint256 _questionType,
        uint256 _questionNumber
    ) public view returns (string[] memory) {
        return questions[_questionType][_questionNumber].options;
    }

    function getCorrectOptionIndex(
        uint256 _questionType,
        uint256 _questionNumber
    ) public view returns (uint256) {
        return questions[_questionType][_questionNumber].correctOptionIndex;
    }

    function getResult(
        address _participantAddress,
        uint256 _questionType
    ) external returns (uint256, string memory) {
        uint rightPick = rightPicked[_participantAddress][_questionType];
        uint256 totalQuestion = totalQuestions[_questionType];
        if (
            questionAnswered[msg.sender][_questionType][totalQuestion] == true
        ) {
            string memory _feedback = provideFeedback(
                _participantAddress,
                _questionType,
                rightPick
            );
            return (rightPick, _feedback);
        } else {
            revert AnswerALLQuestion();
        }
    }

    function provideFeedback(
        address _participantAddress,
        uint256 _questionType,
        uint256 _rightPick
    ) internal returns (string memory) {
        uint256 totalQuestion = totalQuestions[_questionType];
        uint percentage = (_rightPick * 100) / totalQuestion;

        if (percentage >= 100) {
            feedback[_participantAddress][_questionType] = "Excellent";
        } else if (percentage >= 70) {
            feedback[_participantAddress][_questionType] = "Very Good";
        } else if (percentage >= 50) {
            feedback[_participantAddress][_questionType] = "Good";
        } else if (percentage >= 30) {
            feedback[_participantAddress][_questionType] = "Fair";
        } else {
            feedback[_participantAddress][_questionType] = "Poor";
        }

        emit FeedbackProvided();

        return feedback[_participantAddress][_questionType];
    }

    function getFeedback(
        address _participantAddress,
        uint256 _questionType
    ) external view returns (string memory) {
        return feedback[_participantAddress][_questionType];
    }
}
