// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.9;

contract SkillTest {
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

    struct Question {
        string questionText;
        string[] options;
        uint256 correctOptionIndex;
    }

    mapping(uint256 => mapping(uint256 => Question)) questions;
    mapping(uint256 => mapping(uint256 => bool)) questionUploaded;
    mapping(uint256 => uint256) totalQuestions;
    mapping(address => mapping(uint256 => mapping(uint256 => bool))) questionAnswered;
    mapping(address => mapping(uint256 => uint256)) rightPicked;

    function addQuestion(
        uint256 _questionType,
        uint256 _questionNumber,
        string memory _questionText,
        string[] memory _options,
        uint256 _correctOptionIndex
    ) external {
        require(
            questionUploaded[_questionType][_questionNumber] == false,
            "question number already filled"
        );
        require(_options.length >= 2, "Question must have at least 2 options.");
        require(
            _correctOptionIndex < _options.length,
            "Correct option index must be less than the number of options."
        );
        questions[_questionType][_questionNumber] = Question(
            _questionText,
            _options,
            _correctOptionIndex
        );
        questionUploaded[_questionType][_questionNumber] = true;
        totalQuestions[_questionType] += 1;
    }

    function changeCorrectOptionIndex(
        uint256 _questionType,
        uint256 _questionNumber,
        uint256 _correctOptionIndex
    ) external {
        questions[_questionType][_questionNumber]
            .correctOptionIndex = _correctOptionIndex;
    }

    function answerQuestion(
        uint256 _questionType,
        uint256 _questionNumber,
        uint256 _chosenOptionIndex
    ) external returns (bool) {
        require(
            questionAnswered[msg.sender][_questionType][_questionNumber] ==
                false,
            "question already answer"
        );
        require(
            _chosenOptionIndex <
                questions[_questionType][_questionNumber].options.length,
            "Chosen option index must be less than the number of options."
        );
        questionAnswered[msg.sender][_questionType][_questionNumber] = true;
        if (
            _chosenOptionIndex ==
            questions[_questionType][_questionNumber].correctOptionIndex
        ) {
            rightPicked[msg.sender][_questionType] += 1;
            return true;
        }
        return false;
    }

    //access control
    function retake(
        address _participantAddress,
        uint256 _questionType
    ) external {
        uint total = totalQuestions[_questionType];
        for (
            uint256 _questionNumber;
            _questionNumber < total;
            _questionNumber++
        ) {
            questionAnswered[_participantAddress][_questionType][
                _questionNumber
            ] = false;
        }
    }

    //get all question in a Category
    // access control
    function getAllquestion(
        uint256 _questionType
    ) external view returns (Question[] memory) {
        uint total = totalQuestions[_questionType];
        Question[] memory allQuestion = new Question[](total);

        for (uint256 i; i < total; i++) {
            allQuestion[i] = questions[_questionType][i + 1];
        }

        return allQuestion;
    }
}
