# Health Data LOD Design & RDF Templates

This document outlines the strategy for transforming internal application data (MongoDB models) into **Linked Open Data (LOD)** compliant with privacy standards and semantic web best practices.

## 1. Core Principles (Criteria for Health LOD)

To ensure data value and privacy, we adhere to the following principles:

- **Anonymization (Privacy First):**
  - **No PII:** Names, emails, phone numbers, and exact addresses are strictly excluded.
  - **De-identification:** Users are represented by random UUIDs or blank nodes, not their database IDs if those can be traced back.
  - **Generalization:** Dates of birth are converted to **Year of Birth**. Exact timestamps are rounded to **Date** or **Time Blocks** (Morning, Afternoon) where precise timing isn't critical for the research value.
- **Standardization (Ontologies):**
  - **SOSA/SSN:** For sensor data (WatchLogs).
  - **SNOMED CT:** For clinical terms and health metrics.
  - **LOINC:** For observations and measurements.
  - **FHIR RDF:** For health records structure.
  - **Schema.org / FOAF:** For basic person attributes (gender).
- **FAIR Principles:** Data will be Findable, Accessible, Interoperable, and Reusable.

## 2. Prefixes & Namespaces

```turtle
@prefix : <http://omnimer.health/data/> .
@prefix ont: <http://omnimer.health/ontology/> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
@prefix sosa: <http://www.w3.org/ns/sosa/> .
@prefix ssn: <http://www.w3.org/ns/ssn/> .
@prefix snomed: <http://snomed.info/id/> .
@prefix loinc: <http://loinc.org/rdf/> .
@prefix fhir: <http://hl7.org/fhir/> .
@prefix schema: <http://schema.org/> .
@prefix foaf: <http://xmlns.com/foaf/0.1/> .
@prefix unit: <http://qudt.org/vocab/unit/> .
@prefix prov: <http://www.w3.org/ns/prov#> .
```

## 3. Data Models & RDF Templates

### 3.1. User Profile (Demographics)

**Source Model:** `User.model.ts`
**Transformation Logic:**

- **Keep:** `gender`, `birthday` (convert to Year).
- **Add:** `isDataSharingAccepted` (Boolean) - _Only export if True_.
- **Exclude:** `fullname`, `email`, `password`, `imageUrl`, `roleIds`, `verification` fields.

**RDF Template (Turtle):**

```turtle
# Subject: Anonymized User UUID (e.g., generated hash)
:user_a1b2c3d4 a schema:Person ;
    schema:gender schema:Male ; # Map GenderEnum to schema:Male/Female
    schema:birthDate "1998"^^xsd:gYear ; # Only Year
    ont:hasConsent "true"^^xsd:boolean .
```

### 3.2. Health Profile (Clinical Metrics)

**Source Model:** `HealthProfile.model.ts`
**Transformation Logic:**

- **Keep:** `height`, `weight`, `bmi`, `bodyFatPercentage`, `restingHeartRate`, `bloodPressure`.
- **Exclude:** `notes`, `painLocations` (free text), `userId` (link to anonymized ID).
- **Map:**
  - BMI -> LOINC `39156-5`
  - Body Fat -> LOINC `41982-0`
  - Heart Rate -> SNOMED `364075005`

**RDF Template (Turtle):**

```turtle
:obs_hp_001 a sosa:Observation ;
    sosa:hasFeatureOfInterest :user_a1b2c3d4 ;
    sosa:resultTime "2025-11-30"^^xsd:date ;

    # BMI
    sosa:hasMember [
        a sosa:Observation ;
        sosa:observedProperty loinc:39156-5 ; # Body Mass Index
        sosa:hasSimpleResult "24.5"^^xsd:decimal ;
        sosa:hasResultUnit unit:KiloGM-M2
    ] ;

    # Body Fat
    sosa:hasMember [
        a sosa:Observation ;
        sosa:observedProperty loinc:41982-0 ; # Body fat percentage
        sosa:hasSimpleResult "18.5"^^xsd:decimal ;
        sosa:hasResultUnit unit:Percent
    ] ;

    # Resting Heart Rate
    sosa:hasMember [
        a sosa:Observation ;
        sosa:observedProperty snomed:364075005 ; # Heart rate
        sosa:hasSimpleResult "60"^^xsd:integer ;
        sosa:hasResultUnit unit:BeatsPerMinute
    ] .
```

### 3.3. Watch Log (Sensor Data)

**Source Model:** `WatchLog.model.ts`
**Transformation Logic:**

- **Keep:** `date`, `deviceType`, `steps`, `caloriesTotal`, `sleepDuration`, `heartRateAvg`.
- **Exclude:** `nameDevice`, `sourceBundleId` (unless needed for provenance, then hash it).

**RDF Template (Turtle):**

```turtle
:log_wl_998877 a sosa:ObservationCollection ;
    sosa:hasFeatureOfInterest :user_a1b2c3d4 ;
    sosa:resultTime "2025-11-30"^^xsd:date ;
    prov:wasGeneratedBy [
        a sosa:Sensor ;
        rdfs:label "SmartWatch" ; # deviceType
        ont:deviceType "GalaxyWatch"
    ] ;

    # Steps
    sosa:hasMember [
        a sosa:Observation ;
        sosa:observedProperty loinc:55423-8 ; # Number of steps
        sosa:hasSimpleResult "8500"^^xsd:integer
    ] ;

    # Calories Burned
    sosa:hasMember [
        a sosa:Observation ;
        sosa:observedProperty loinc:41981-2 ; # Calories burned
        sosa:hasSimpleResult "450"^^xsd:decimal ;
        sosa:hasResultUnit unit:KiloCalorie
    ] ;

    # Sleep Duration
    sosa:hasMember [
        a sosa:Observation ;
        sosa:observedProperty snomed:248263006 ; # Duration of sleep
        sosa:hasSimpleResult "420"^^xsd:integer ; # Minutes
        sosa:hasResultUnit unit:Minute
    ] .
```

### 3.4. Workout Session (Activity)

**Source Model:** `Workout.model.ts`
**Transformation Logic:**

- **Keep:** `timeStart` (Date), `workoutDetail` (Exercise Name/ID, Reps, Sets, Weight), `summary`.
- **Exclude:** `notes`.

**RDF Template (Turtle):**

```turtle
:workout_wk_556677 a schema:ExerciseAction ;
    schema:agent :user_a1b2c3d4 ;
    schema:startTime "2025-11-30T18:00:00"^^xsd:dateTime ;
    schema:endTime "2025-11-30T19:00:00"^^xsd:dateTime ;

    # Summary
    ont:totalCalories "300"^^xsd:integer ;
    ont:avgHeartRate "135"^^xsd:integer ;

    # Detailed Exercises
    schema:instrument [
        a ont:ExerciseSession ;
        ont:exerciseName "Bench Press" ; # Or link to exercise ontology ID
        ont:sets [
            a ont:Set ;
            ont:reps 10 ;
            ont:weight 60.0 ; # kg
            ont:order 1
        ] ;
        ont:sets [
            a ont:Set ;
            ont:reps 8 ;
            ont:weight 65.0 ;
            ont:order 2
        ]
    ] .
```

### 3.5. Goals

**Source Model:** `Goal.model.ts`
**Transformation Logic:**

- **Keep:** `goalType`, `targetMetric`, `startDate`, `endDate`.

**RDF Template (Turtle):**

```turtle
:goal_gl_112233 a fhir:Goal ;
    fhir:Goal.subject [ fhir:Reference.reference "User/a1b2c3d4" ] ;
    fhir:Goal.description [ fhir:value "Lose Weight" ] ; # goalType
    fhir:Goal.startDate [ fhir:value "2025-01-01"^^xsd:date ] ;

    fhir:Goal.target [
        fhir:Goal.target.measure [
            fhir:CodeableConcept.coding [
                fhir:Coding.system <http://loinc.org> ;
                fhir:Coding.code "29463-7" ; # Body weight
            ]
        ] ;
        fhir:Goal.target.detailQuantity [
            fhir:Quantity.value 70 ;
            fhir:Quantity.unit "kg"
        ]
    ] .
```

## 4. Implementation Strategy

1.  **Update User Model:** Add `isDataSharingAccepted: { type: Boolean, default: false }` to `User.model.ts`.
2.  **Data Pipeline:**
    - Create a background job or event listener (e.g., `OnWorkoutCompleted`, `OnDailyLogCreated`).
    - Check `user.isDataSharingAccepted`.
    - If true, map the data to the RDF format defined above.
    - Push to GraphDB using SPARQL UPDATE or HTTP Import.
