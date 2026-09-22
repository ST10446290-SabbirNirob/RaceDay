-- ============================================================
-- RaceDay Event Management System
-- Database Setup and Seed Data Script
-- ============================================================
-- This script:
-- 1. Creates the RaceDay database if it does not exist.
-- 2. Creates all tables required by the RaceDay ERD.
-- 3. Adds primary keys, foreign keys and other constraints.
-- 4. Inserts realistic sample data.
-- ============================================================


-- ============================================================
-- CREATE DATABASE
-- ============================================================

IF DB_ID('RaceDay') IS NULL
BEGIN
    CREATE DATABASE RaceDay;
END;
GO


-- ============================================================
-- USE DATABASE
-- ============================================================

USE RaceDay;
GO


-- ============================================================
-- USER TABLE
-- Stores both Organisers and Participants
-- ============================================================

IF OBJECT_ID('dbo.[User]', 'U') IS NULL
BEGIN

    CREATE TABLE dbo.[User]
    (
        UserID INT IDENTITY(1,1) NOT NULL,
        FirstName VARCHAR(50) NOT NULL,
        LastName VARCHAR(50) NOT NULL,
        Email VARCHAR(100) NOT NULL,
        PasswordHash VARCHAR(255) NOT NULL,
        Role VARCHAR(20) NOT NULL,
        CreatedAt DATETIME NOT NULL
            CONSTRAINT DF_User_CreatedAt DEFAULT GETDATE(),

        CONSTRAINT PK_User
            PRIMARY KEY (UserID),

        CONSTRAINT UQ_User_Email
            UNIQUE (Email),

        CONSTRAINT CK_User_Role
            CHECK (Role IN ('Organiser', 'Participant'))
    );

END;
GO


-- ============================================================
-- EVENT TABLE
-- Stores events created by Organisers
-- ============================================================

IF OBJECT_ID('dbo.Event', 'U') IS NULL
BEGIN

    CREATE TABLE dbo.Event
    (
        EventID INT IDENTITY(1,1) NOT NULL,
        OrganiserID INT NOT NULL,
        EventName VARCHAR(100) NOT NULL,
        Description VARCHAR(500) NULL,
        EventDate DATETIME NOT NULL,
        Location VARCHAR(150) NOT NULL,
        EventType VARCHAR(30) NOT NULL,
        RegistrationDeadline DATETIME NOT NULL,

        CONSTRAINT PK_Event
            PRIMARY KEY (EventID),

        CONSTRAINT FK_Event_Organiser
            FOREIGN KEY (OrganiserID)
            REFERENCES dbo.[User](UserID)
    );

END;
GO


-- ============================================================
-- CATEGORY TABLE
-- Stores the categories available for each event
-- ============================================================

IF OBJECT_ID('dbo.Category', 'U') IS NULL
BEGIN

    CREATE TABLE dbo.Category
    (
        CategoryID INT IDENTITY(1,1) NOT NULL,
        EventID INT NOT NULL,
        CategoryName VARCHAR(100) NOT NULL,
        DistanceKm DECIMAL(6,2) NOT NULL,
        EntryFee DECIMAL(10,2) NOT NULL,
        MaxParticipants INT NOT NULL,

        CONSTRAINT PK_Category
            PRIMARY KEY (CategoryID),

        CONSTRAINT FK_Category_Event
            FOREIGN KEY (EventID)
            REFERENCES dbo.Event(EventID)
    );

END;
GO


-- ============================================================
-- ROUTE TABLE
-- Stores route information for events
-- ============================================================

IF OBJECT_ID('dbo.Route', 'U') IS NULL
BEGIN

    CREATE TABLE dbo.Route
    (
        RouteID INT IDENTITY(1,1) NOT NULL,
        EventID INT NOT NULL,
        RouteName VARCHAR(100) NOT NULL,
        DistanceKm DECIMAL(6,2) NOT NULL,
        StartLocation VARCHAR(150) NOT NULL,
        FinishLocation VARCHAR(150) NOT NULL,
        RouteInfo VARCHAR(500) NULL,

        CONSTRAINT PK_Route
            PRIMARY KEY (RouteID),

        CONSTRAINT FK_Route_Event
            FOREIGN KEY (EventID)
            REFERENCES dbo.Event(EventID)
    );

END;
GO


-- ============================================================
-- ENROLMENT TABLE
-- Stores participant registrations for events
-- ============================================================

IF OBJECT_ID('dbo.Enrolment', 'U') IS NULL
BEGIN

    CREATE TABLE dbo.Enrolment
    (
        EnrolmentID INT IDENTITY(1,1) NOT NULL,
        ParticipantID INT NOT NULL,
        EventID INT NOT NULL,
        CategoryID INT NOT NULL,
        EnrolmentDate DATETIME NOT NULL
            CONSTRAINT DF_Enrolment_Date DEFAULT GETDATE(),
        Status VARCHAR(20) NOT NULL,
        RaceNumber VARCHAR(20) NOT NULL,

        CONSTRAINT PK_Enrolment
            PRIMARY KEY (EnrolmentID),

        CONSTRAINT UQ_Enrolment_RaceNumber
            UNIQUE (RaceNumber),

        CONSTRAINT FK_Enrolment_Participant
            FOREIGN KEY (ParticipantID)
            REFERENCES dbo.[User](UserID),

        CONSTRAINT FK_Enrolment_Event
            FOREIGN KEY (EventID)
            REFERENCES dbo.Event(EventID),

        CONSTRAINT FK_Enrolment_Category
            FOREIGN KEY (CategoryID)
            REFERENCES dbo.Category(CategoryID)
    );

END;
GO


-- ============================================================
-- RESULT TABLE
-- Stores results for participant enrolments
-- ============================================================

IF OBJECT_ID('dbo.Result', 'U') IS NULL
BEGIN

    CREATE TABLE dbo.Result
    (
        ResultID INT IDENTITY(1,1) NOT NULL,
        EnrolmentID INT NOT NULL,
        FinishTime TIME NOT NULL,
        OverallPosition INT NULL,
        CategoryPosition INT NULL,
        RecordedAt DATETIME NOT NULL
            CONSTRAINT DF_Result_RecordedAt DEFAULT GETDATE(),

        CONSTRAINT PK_Result
            PRIMARY KEY (ResultID),

        CONSTRAINT UQ_Result_Enrolment
            UNIQUE (EnrolmentID),

        CONSTRAINT FK_Result_Enrolment
            FOREIGN KEY (EnrolmentID)
            REFERENCES dbo.Enrolment(EnrolmentID)
    );

END;
GO


-- ============================================================
-- SEED DATA
-- Adds realistic sample data to the RaceDay database
-- ============================================================


-- ============================================================
-- SAMPLE USERS
-- 2 Organisers and 2 Participants
-- ============================================================

IF NOT EXISTS
(
    SELECT 1
    FROM dbo.[User]
    WHERE Email = 'thabo@raceday.co.za'
)
BEGIN

    INSERT INTO dbo.[User]
        (FirstName, LastName, Email, PasswordHash, Role)
    VALUES
        ('Thabo', 'Mokoena',
         'thabo@raceday.co.za',
         'SampleHash123',
         'Organiser'),

        ('Sarah', 'Jacobs',
         'sarah@raceday.co.za',
         'SampleHash456',
         'Organiser'),

        ('Sipho', 'Dlamini',
         'sipho@example.com',
         'SampleHash789',
         'Participant'),

        ('Ayesha', 'Khan',
         'ayesha@example.com',
         'SampleHash101',
         'Participant');

END;
GO


-- ============================================================
-- SAMPLE EVENTS
-- 3 South African road events
-- ============================================================

IF NOT EXISTS
(
    SELECT 1
    FROM dbo.Event
    WHERE EventName = 'Cape Town City Run'
)
BEGIN

    DECLARE @ThaboID INT;
    DECLARE @SarahID INT;

    SELECT @ThaboID = UserID
    FROM dbo.[User]
    WHERE Email = 'thabo@raceday.co.za';

    SELECT @SarahID = UserID
    FROM dbo.[User]
    WHERE Email = 'sarah@raceday.co.za';


    INSERT INTO dbo.Event
        (
            OrganiserID,
            EventName,
            Description,
            EventDate,
            Location,
            EventType,
            RegistrationDeadline
        )
    VALUES

        (
            @ThaboID,
            'Cape Town City Run',
            'A road running event through central Cape Town.',
            '2026-11-15 07:00:00',
            'Cape Town, Western Cape',
            'Running',
            '2026-11-08 23:59:00'
        ),

        (
            @SarahID,
            'Durban Coastal Cycle',
            'A cycling event along the Durban coastline.',
            '2026-12-05 06:30:00',
            'Durban, KwaZulu-Natal',
            'Cycling',
            '2026-11-28 23:59:00'
        ),

        (
            @ThaboID,
            'Johannesburg Charity Walk',
            'A community walking event supporting local charities.',
            '2027-01-23 08:00:00',
            'Johannesburg, Gauteng',
            'Walking',
            '2027-01-16 23:59:00'
        );

END;
GO


-- ============================================================
-- SAMPLE CATEGORIES
-- Adds categories for each event
-- ============================================================

IF NOT EXISTS (SELECT 1 FROM dbo.Category)
BEGIN

    DECLARE @CapeTownEventID INT;
    DECLARE @DurbanEventID INT;
    DECLARE @JohannesburgEventID INT;


    SELECT @CapeTownEventID = EventID
    FROM dbo.Event
    WHERE EventName = 'Cape Town City Run';


    SELECT @DurbanEventID = EventID
    FROM dbo.Event
    WHERE EventName = 'Durban Coastal Cycle';


    SELECT @JohannesburgEventID = EventID
    FROM dbo.Event
    WHERE EventName = 'Johannesburg Charity Walk';


    INSERT INTO dbo.Category
        (
            EventID,
            CategoryName,
            DistanceKm,
            EntryFee,
            MaxParticipants
        )
    VALUES

        -- Cape Town City Run
        (@CapeTownEventID,
         '5 km Fun Run',
         5.00,
         100.00,
         500),

        (@CapeTownEventID,
         '10 km Run',
         10.00,
         180.00,
         400),

        (@CapeTownEventID,
         'Half Marathon',
         21.10,
         300.00,
         300),


        -- Durban Coastal Cycle
        (@DurbanEventID,
         '20 km Cycle',
         20.00,
         200.00,
         350),

        (@DurbanEventID,
         '50 km Cycle',
         50.00,
         350.00,
         250),


        -- Johannesburg Charity Walk
        (@JohannesburgEventID,
         '5 km Walk',
         5.00,
         80.00,
         600),

        (@JohannesburgEventID,
         '10 km Walk',
         10.00,
         120.00,
         400);

END;
GO


-- ============================================================
-- SAMPLE ROUTES
-- Adds route information for each event
-- ============================================================

IF NOT EXISTS (SELECT 1 FROM dbo.Route)
BEGIN

    DECLARE @CapeTownEventID INT;
    DECLARE @DurbanEventID INT;
    DECLARE @JohannesburgEventID INT;


    SELECT @CapeTownEventID = EventID
    FROM dbo.Event
    WHERE EventName = 'Cape Town City Run';


    SELECT @DurbanEventID = EventID
    FROM dbo.Event
    WHERE EventName = 'Durban Coastal Cycle';


    SELECT @JohannesburgEventID = EventID
    FROM dbo.Event
    WHERE EventName = 'Johannesburg Charity Walk';


    INSERT INTO dbo.Route
        (
            EventID,
            RouteName,
            DistanceKm,
            StartLocation,
            FinishLocation,
            RouteInfo
        )
    VALUES

        (
            @CapeTownEventID,
            'Cape Town City Route',
            21.10,
            'Cape Town CBD',
            'Green Point',
            'Road route through central Cape Town.'
        ),

        (
            @DurbanEventID,
            'Durban Coastal Route',
            50.00,
            'Durban Beachfront',
            'Umhlanga',
            'Coastal cycling route from Durban towards Umhlanga.'
        ),

        (
            @JohannesburgEventID,
            'Johannesburg Charity Route',
            10.00,
            'Johannesburg CBD',
            'Constitution Hill',
            'Community walking route through central Johannesburg.'
        );

END;
GO


-- ============================================================
-- SAMPLE ENROLMENTS
-- Adds participant registrations
-- ============================================================

IF NOT EXISTS (SELECT 1 FROM dbo.Enrolment)
BEGIN

    DECLARE @SiphoID INT;
    DECLARE @AyeshaID INT;

    DECLARE @CapeTownEventID INT;
    DECLARE @DurbanEventID INT;
    DECLARE @JohannesburgEventID INT;

    DECLARE @CapeTown10KmCategoryID INT;
    DECLARE @Durban20KmCategoryID INT;
    DECLARE @Johannesburg5KmCategoryID INT;


    -- Find Participants

    SELECT @SiphoID = UserID
    FROM dbo.[User]
    WHERE Email = 'sipho@example.com';


    SELECT @AyeshaID = UserID
    FROM dbo.[User]
    WHERE Email = 'ayesha@example.com';


    -- Find Events

    SELECT @CapeTownEventID = EventID
    FROM dbo.Event
    WHERE EventName = 'Cape Town City Run';


    SELECT @DurbanEventID = EventID
    FROM dbo.Event
    WHERE EventName = 'Durban Coastal Cycle';


    SELECT @JohannesburgEventID = EventID
    FROM dbo.Event
    WHERE EventName = 'Johannesburg Charity Walk';


    -- Find Categories

    SELECT @CapeTown10KmCategoryID = CategoryID
    FROM dbo.Category
    WHERE EventID = @CapeTownEventID
      AND CategoryName = '10 km Run';


    SELECT @Durban20KmCategoryID = CategoryID
    FROM dbo.Category
    WHERE EventID = @DurbanEventID
      AND CategoryName = '20 km Cycle';


    SELECT @Johannesburg5KmCategoryID = CategoryID
    FROM dbo.Category
    WHERE EventID = @JohannesburgEventID
      AND CategoryName = '5 km Walk';


    -- Add Enrolments

    INSERT INTO dbo.Enrolment
        (
            ParticipantID,
            EventID,
            CategoryID,
            Status,
            RaceNumber
        )
    VALUES

        (
            @SiphoID,
            @CapeTownEventID,
            @CapeTown10KmCategoryID,
            'Confirmed',
            'CT001'
        ),

        (
            @AyeshaID,
            @DurbanEventID,
            @Durban20KmCategoryID,
            'Confirmed',
            'DBN001'
        ),

        (
            @SiphoID,
            @JohannesburgEventID,
            @Johannesburg5KmCategoryID,
            'Confirmed',
            'JHB001'
        );

END;
GO


-- ============================================================
-- SAMPLE RESULTS
-- Adds sample results for completed enrolments
-- ============================================================

IF NOT EXISTS (SELECT 1 FROM dbo.Result)
BEGIN

    DECLARE @CapeTownEnrolmentID INT;
    DECLARE @DurbanEnrolmentID INT;
    DECLARE @JohannesburgEnrolmentID INT;


    SELECT @CapeTownEnrolmentID = EnrolmentID
    FROM dbo.Enrolment
    WHERE RaceNumber = 'CT001';


    SELECT @DurbanEnrolmentID = EnrolmentID
    FROM dbo.Enrolment
    WHERE RaceNumber = 'DBN001';


    SELECT @JohannesburgEnrolmentID = EnrolmentID
    FROM dbo.Enrolment
    WHERE RaceNumber = 'JHB001';


    INSERT INTO dbo.Result
        (
            EnrolmentID,
            FinishTime,
            OverallPosition,
            CategoryPosition
        )
    VALUES

        (
            @CapeTownEnrolmentID,
            '00:54:32',
            42,
            15
        ),

        (
            @DurbanEnrolmentID,
            '01:18:45',
            28,
            9
        ),

        (
            @JohannesburgEnrolmentID,
            '00:48:10',
            35,
            11
        );

END;
GO


-- ============================================================
-- VERIFICATION QUERIES
-- Displays the sample data after the script has run
-- ============================================================

SELECT * FROM dbo.[User];
SELECT * FROM dbo.Event;
SELECT * FROM dbo.Category;
SELECT * FROM dbo.Route;
SELECT * FROM dbo.Enrolment;
SELECT * FROM dbo.Result;
GO