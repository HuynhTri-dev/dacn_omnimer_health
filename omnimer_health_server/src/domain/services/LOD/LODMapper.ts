import { Writer, DataFactory } from "n3";
import { IUser } from "../../models/Profile/User.model";
import { IHealthProfile } from "../../models/Profile/HealthProfile.model";
import { IWatchLog } from "../../models/Devices/WatchLog.model";
import { IWorkout } from "../../models/Workout/Workout.model";
import { IGoal } from "../../models/Profile/Goal.model";
import { IExercise } from "../../models/Exercise/Exercise.model";
import { GenderEnum } from "../../../common/constants/EnumConstants";

const { namedNode, literal, quad, blankNode } = DataFactory;

const PREFIXES = {
  "": "http://omnimer.health/data/",
  ont: "http://omnimer.health/ontology/",
  xsd: "http://www.w3.org/2001/XMLSchema#",
  sosa: "http://www.w3.org/ns/sosa/",
  ssn: "http://www.w3.org/ns/ssn/",
  snomed: "http://snomed.info/id/",
  loinc: "http://loinc.org/rdf/",
  fhir: "http://hl7.org/fhir/",
  schema: "http://schema.org/",
  foaf: "http://xmlns.com/foaf/0.1/",
  unit: "http://qudt.org/vocab/unit/",
  prov: "http://www.w3.org/ns/prov#",
  rdfs: "http://www.w3.org/2000/01/rdf-schema#",
};

export class LODMapper {
  private static getWriter() {
    return new Writer({ prefixes: PREFIXES });
  }

  private static getUserURI(userId: string): string {
    return `${PREFIXES[""]}user_${userId}`;
  }

  // Helper to create anonymized user ID (simple hash for demo - use proper hashing in production)
  private static hashUserId(userId: string): string {
    // In production, use proper cryptographic hash (SHA-256) with salt
    return btoa(userId.substring(0, 8))
      .replace(/[^a-zA-Z0-9]/g, "")
      .substring(0, 8);
  }

  // === DATA VALIDATION HELPERS ===

  private static validateAndSanitize(value: any, property: string): any {
    if (value === undefined || value === null) return undefined;

    // Remove potential PII for sensitive fields
    if (
      property.includes("name") ||
      property.includes("email") ||
      property.includes("phone")
    ) {
      return undefined; // Exclude PII from RDF
    }

    // Validate ranges
    if (typeof value === "number") {
      if (isNaN(value)) return undefined;
      if (property.includes("heartRate") && (value < 30 || value > 220))
        return undefined;
      if (property.includes("weight") && (value < 0 || value > 1000))
        return undefined;
      if (property.includes("height") && (value < 0 || value > 300))
        return undefined;
      if (property.includes("bloodPressure") && (value < 40 || value > 250))
        return undefined;
    }

    return value;
  }

  // === EXPORT FUNCTIONS ===

  static exportAllUserData(
    user: IUser,
    healthProfiles: IHealthProfile[],
    watchLogs: IWatchLog[],
    workouts: IWorkout[],
    goals: IGoal[],
    exercises?: IExercise[]
  ): string {
    const writer = new Writer({ prefixes: PREFIXES });
    const rdfData: string[] = [];

    // Only export if user has consented
    if (!user?.isDataSharingAccepted) {
      return "";
    }

    // Add user data
    const userRdf = this.mapUserToRDF(user);
    if (userRdf) rdfData.push(userRdf);

    // Add health profiles
    healthProfiles.forEach((profile) => {
      const profileRdf = this.mapHealthProfileToRDF(profile);
      if (profileRdf) rdfData.push(profileRdf);
    });

    // Add watch logs
    watchLogs.forEach((log) => {
      const logRdf = this.mapWatchLogToRDF(log);
      if (logRdf) rdfData.push(logRdf);
    });

    // Add workouts
    workouts.forEach((workout) => {
      const workoutRdf = this.mapWorkoutToRDF(workout);
      if (workoutRdf) rdfData.push(workoutRdf);
    });

    // Add goals
    goals.forEach((goal) => {
      const goalRdf = this.mapGoalToRDF(goal);
      if (goalRdf) rdfData.push(goalRdf);
    });

    // Add exercises (if provided)
    if (exercises) {
      exercises.forEach((exercise) => {
        const exerciseRdf = this.mapExerciseToRDF(exercise);
        if (exerciseRdf) rdfData.push(exerciseRdf);
      });
    }

    return rdfData.join("\n\n");
  }

  // === PRIVACY CONTROL ===

  static hasUserConsent(user?: IUser): boolean {
    return user?.isDataSharingAccepted || false;
  }

  static filterSensitiveData(
    data: any,
    sensitiveFields: string[] = ["email", "phone", "address", "ssn"]
  ): any {
    const filtered: any = {};
    Object.keys(data).forEach((key) => {
      if (!sensitiveFields.some((field) => key.toLowerCase().includes(field))) {
        filtered[key] = data[key];
      }
    });
    return filtered;
  }

  // Helper to add observation with proper structure
  private static addObservation(
    writer: Writer,
    subject: any,
    predicate: string,
    value: any,
    unit?: string,
    dataType: string = "decimal"
  ): void {
    if (value === undefined || value === null) return;

    const observationNode = blankNode();
    writer.addQuad(
      subject,
      namedNode(PREFIXES.sosa + "hasMember"),
      observationNode
    );
    writer.addQuad(
      observationNode,
      namedNode("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"),
      namedNode(PREFIXES.sosa + "Observation")
    );
    writer.addQuad(
      observationNode,
      namedNode(PREFIXES.sosa + "observedProperty"),
      namedNode(predicate)
    );
    writer.addQuad(
      observationNode,
      namedNode(PREFIXES.sosa + "hasSimpleResult"),
      literal(value.toString(), namedNode(PREFIXES.xsd + dataType))
    );

    if (unit) {
      writer.addQuad(
        observationNode,
        namedNode(PREFIXES.sosa + "hasResultUnit"),
        namedNode(PREFIXES.unit + unit)
      );
    }
  }

  static mapUserToRDF(user: IUser): string {
    if (!user.isDataSharingAccepted) return "";

    const writer = this.getWriter();
    // Create anonymized user URI for privacy
    const userHash = this.hashUserId(user._id.toString());
    const subject = namedNode(PREFIXES[""] + userHash);

    // Type: Person
    writer.addQuad(
      subject,
      namedNode("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"),
      namedNode(PREFIXES.schema + "Person")
    );

    // Gender (if available)
    if (user.gender) {
      writer.addQuad(
        subject,
        namedNode(PREFIXES.schema + "gender"),
        literal(user.gender)
      );
    }

    // Year of Birth (only year, not full date for privacy)
    if (user.birthday) {
      const year = new Date(user.birthday).getFullYear().toString();
      writer.addQuad(
        subject,
        namedNode(PREFIXES.schema + "birthYear"),
        literal(year, namedNode(PREFIXES.xsd + "gYear"))
      );
    }

    // Data sharing consent flag
    writer.addQuad(
      subject,
      namedNode(PREFIXES.ont + "hasConsent"),
      literal("true", namedNode(PREFIXES.xsd + "boolean"))
    );

    let rdfOutput = "";
    writer.end((error, result) => (rdfOutput = result));
    return rdfOutput;
  }

  static mapHealthProfileToRDF(profile: IHealthProfile): string {
    const writer = this.getWriter();
    const subject = namedNode(`${PREFIXES[""]}hp_${profile._id}`);
    const userHash = this.hashUserId(profile.userId.toString());
    const userSubject = namedNode(PREFIXES[""] + userHash);

    writer.addQuad(
      subject,
      namedNode("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"),
      namedNode(PREFIXES.sosa + "Observation")
    );

    writer.addQuad(
      subject,
      namedNode(PREFIXES.sosa + "hasFeatureOfInterest"),
      userSubject
    );

    if (profile.checkupDate) {
      const dateStr = new Date(profile.checkupDate).toISOString().split("T")[0];
      writer.addQuad(
        subject,
        namedNode(PREFIXES.sosa + "resultTime"),
        literal(dateStr, namedNode(PREFIXES.xsd + "date"))
      );
    }

    // === ANTHROPOMETRIC MEASUREMENTS (LOINC) ===

    // Body Mass Index - LOINC 39156-5
    this.addObservation(
      writer,
      subject,
      PREFIXES.loinc + "39156-5",
      profile.bmi,
      "KiloGM-M2"
    );

    // Body Fat Percentage - LOINC 41982-0
    this.addObservation(
      writer,
      subject,
      PREFIXES.loinc + "41982-0",
      profile.bodyFatPercentage,
      "Percent"
    );

    // Body Weight - LOINC 29463-7
    this.addObservation(
      writer,
      subject,
      PREFIXES.loinc + "29463-7",
      profile.weight,
      "KiloGM"
    );

    // Body Height - LOINC 8302-2
    this.addObservation(
      writer,
      subject,
      PREFIXES.loinc + "8302-2",
      profile.height,
      "CentiM"
    );

    // Waist Circumference - LOINC 8280-0
    this.addObservation(
      writer,
      subject,
      PREFIXES.loinc + "8280-0",
      profile.waist,
      "CentiM"
    );

    // Hip Circumference - LOINC 8281-8
    this.addObservation(
      writer,
      subject,
      PREFIXES.loinc + "8281-8",
      profile.hip,
      "CentiM"
    );

    // Neck Circumference - LOINC 33748-5
    this.addObservation(
      writer,
      subject,
      PREFIXES.loinc + "33748-5",
      profile.neck,
      "CentiM"
    );

    // === CARDIOVASCULAR MEASUREMENTS (SNOMED) ===

    // Resting Heart Rate - SNOMED 364075005
    this.addObservation(
      writer,
      subject,
      PREFIXES.snomed + "364075005",
      profile.restingHeartRate,
      "BeatsPerMinute",
      "integer"
    );

    // Systolic Blood Pressure - SNOMED 271649006
    if (profile.bloodPressure?.systolic) {
      this.addObservation(
        writer,
        subject,
        PREFIXES.snomed + "271649006",
        profile.bloodPressure.systolic,
        "MilliMHG",
        "integer"
      );
    }

    // Diastolic Blood Pressure - SNOMED 271650006
    if (profile.bloodPressure?.diastolic) {
      this.addObservation(
        writer,
        subject,
        PREFIXES.snomed + "271650006",
        profile.bloodPressure.diastolic,
        "MilliMHG",
        "integer"
      );
    }

    // === METABOLIC MEASUREMENTS ===

    // Total Cholesterol - LOINC 2093-3
    if (profile.cholesterol?.total) {
      this.addObservation(
        writer,
        subject,
        PREFIXES.loinc + "2093-3",
        profile.cholesterol.total,
        "MilliMOL-PER-L"
      );
    }

    // LDL Cholesterol - LOINC 2089-1
    if (profile.cholesterol?.ldl) {
      this.addObservation(
        writer,
        subject,
        PREFIXES.loinc + "2089-1",
        profile.cholesterol.ldl,
        "MilliMOL-PER-L"
      );
    }

    // HDL Cholesterol - LOINC 2085-9
    if (profile.cholesterol?.hdl) {
      this.addObservation(
        writer,
        subject,
        PREFIXES.loinc + "2085-9",
        profile.cholesterol.hdl,
        "MilliMOL-PER-L"
      );
    }

    // Blood Glucose - LOINC 2345-7
    if (profile.bloodSugar) {
      this.addObservation(
        writer,
        subject,
        PREFIXES.loinc + "2345-7",
        profile.bloodSugar,
        "MilliMOL-PER-L"
      );
    }

    // Basal Metabolic Rate - LOINC 39156-7
    if (profile.bmr) {
      this.addObservation(
        writer,
        subject,
        PREFIXES.loinc + "39156-7",
        profile.bmr,
        "KiloCAL-PER-DAY",
        "integer"
      );
    }

    // === FITNESS ASSESSMENTS ===

    // Muscle Mass - Custom property
    if (profile.muscleMass) {
      this.addObservation(
        writer,
        subject,
        PREFIXES.ont + "muscleMass",
        profile.muscleMass,
        "KiloGM"
      );
    }

    // Maximum Push-ups - Custom property
    if (profile.maxPushUps) {
      this.addObservation(
        writer,
        subject,
        PREFIXES.ont + "maxPushUps",
        profile.maxPushUps,
        "Count",
        "integer"
      );
    }

    // Maximum Weight Lifted - Custom property
    if (profile.maxWeightLifted) {
      this.addObservation(
        writer,
        subject,
        PREFIXES.ont + "maxWeightLifted",
        profile.maxWeightLifted,
        "KiloGM"
      );
    }

    // Activity Level - Custom property
    if (profile.activityLevel) {
      this.addObservation(
        writer,
        subject,
        PREFIXES.ont + "activityLevel",
        profile.activityLevel,
        "Scale",
        "integer"
      );
    }

    // Experience Level - Custom property
    if (profile.experienceLevel) {
      this.addObservation(
        writer,
        subject,
        PREFIXES.ont + "experienceLevel",
        profile.experienceLevel,
        "Code"
      );
    }

    // Workout Frequency - Custom property
    if (profile.workoutFrequency) {
      this.addObservation(
        writer,
        subject,
        PREFIXES.ont + "workoutFrequency",
        profile.workoutFrequency,
        "Times-PER-WEEK",
        "integer"
      );
    }

    // === HEALTH STATUS (SNOMED CT) ===

    if (profile.healthStatus) {
      // Known Conditions - SNOMED CT concepts
      if (profile.healthStatus.knownConditions) {
        profile.healthStatus.knownConditions.forEach((condition, index) => {
          const conditionNode = blankNode();
          writer.addQuad(
            subject,
            namedNode(PREFIXES.sosa + "hasMember"),
            conditionNode
          );
          writer.addQuad(
            conditionNode,
            namedNode("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"),
            namedNode(PREFIXES.sosa + "Observation")
          );
          writer.addQuad(
            conditionNode,
            namedNode(PREFIXES.sosa + "observedProperty"),
            namedNode(PREFIXES.snomed + "404684003")
          ); // Clinical finding
          writer.addQuad(
            conditionNode,
            namedNode(PREFIXES.sosa + "hasSimpleResult"),
            literal(condition, namedNode(PREFIXES.xsd + "string"))
          );
        });
      }

      // Pain Locations - SNOMED CT body structure concepts
      if (profile.healthStatus.painLocations) {
        profile.healthStatus.painLocations.forEach((location, index) => {
          const painNode = blankNode();
          writer.addQuad(
            subject,
            namedNode(PREFIXES.sosa + "hasMember"),
            painNode
          );
          writer.addQuad(
            painNode,
            namedNode("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"),
            namedNode(PREFIXES.sosa + "Observation")
          );
          writer.addQuad(
            painNode,
            namedNode(PREFIXES.sosa + "observedProperty"),
            namedNode(PREFIXES.snomed + "22253000")
          ); // Pain finding
          writer.addQuad(
            painNode,
            namedNode(PREFIXES.sosa + "hasSimpleResult"),
            literal(location, namedNode(PREFIXES.xsd + "string"))
          );
        });
      }

      // Joint Issues - SNOMED CT finding concepts
      if (profile.healthStatus.jointIssues) {
        profile.healthStatus.jointIssues.forEach((issue, index) => {
          const jointNode = blankNode();
          writer.addQuad(
            subject,
            namedNode(PREFIXES.sosa + "hasMember"),
            jointNode
          );
          writer.addQuad(
            jointNode,
            namedNode("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"),
            namedNode(PREFIXES.sosa + "Observation")
          );
          writer.addQuad(
            jointNode,
            namedNode(PREFIXES.sosa + "observedProperty"),
            namedNode(PREFIXES.snomed + "302869004")
          ); // Joint structure finding
          writer.addQuad(
            jointNode,
            namedNode(PREFIXES.sosa + "hasSimpleResult"),
            literal(issue, namedNode(PREFIXES.xsd + "string"))
          );
        });
      }

      // Injuries - SNOMED CT injury concepts
      if (profile.healthStatus.injuries) {
        profile.healthStatus.injuries.forEach((injury, index) => {
          const injuryNode = blankNode();
          writer.addQuad(
            subject,
            namedNode(PREFIXES.sosa + "hasMember"),
            injuryNode
          );
          writer.addQuad(
            injuryNode,
            namedNode("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"),
            namedNode(PREFIXES.sosa + "Observation")
          );
          writer.addQuad(
            injuryNode,
            namedNode(PREFIXES.sosa + "observedProperty"),
            namedNode(PREFIXES.snomed + "281647001")
          ); // Injury
          writer.addQuad(
            injuryNode,
            namedNode(PREFIXES.sosa + "hasSimpleResult"),
            literal(injury, namedNode(PREFIXES.xsd + "string"))
          );
        });
      }
    }

    // === AI EVALUATION ===

    if (profile.aiEvaluation) {
      const aiNode = blankNode();
      writer.addQuad(
        subject,
        namedNode(PREFIXES.ont + "hasAiEvaluation"),
        aiNode
      );
      writer.addQuad(
        aiNode,
        namedNode("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"),
        namedNode(PREFIXES.ont + "AiEvaluation")
      );

      // AI Summary
      if (profile.aiEvaluation.summary) {
        writer.addQuad(
          aiNode,
          namedNode(PREFIXES.ont + "aiSummary"),
          literal(
            profile.aiEvaluation.summary,
            namedNode(PREFIXES.xsd + "string")
          )
        );
      }

      // Health Score - Custom property
      if (profile.aiEvaluation.score !== undefined) {
        this.addObservation(
          writer,
          aiNode,
          PREFIXES.ont + "healthScore",
          profile.aiEvaluation.score,
          "Scale",
          "integer"
        );
      }

      // Risk Level - Custom property
      if (profile.aiEvaluation.riskLevel) {
        writer.addQuad(
          aiNode,
          namedNode(PREFIXES.ont + "riskLevel"),
          literal(
            profile.aiEvaluation.riskLevel,
            namedNode(PREFIXES.xsd + "string")
          )
        );
      }

      // Model Version
      if (profile.aiEvaluation.modelVersion) {
        writer.addQuad(
          aiNode,
          namedNode(PREFIXES.ont + "modelVersion"),
          literal(
            profile.aiEvaluation.modelVersion,
            namedNode(PREFIXES.xsd + "string")
          )
        );
      }

      if (profile.aiEvaluation.updatedAt) {
        writer.addQuad(
          aiNode,
          namedNode(PREFIXES.sosa + "resultTime"),
          literal(
            profile.aiEvaluation.updatedAt.toISOString().split("T")[0],
            namedNode(PREFIXES.xsd + "date")
          )
        );
      }
    }

    let rdfOutput = "";
    writer.end((error, result) => (rdfOutput = result));
    return rdfOutput;
  }

  static mapWatchLogToRDF(log: IWatchLog): string {
    const writer = this.getWriter();
    const subject = namedNode(`${PREFIXES[""]}wl_${log._id}`);
    const userHash = this.hashUserId(log.userId.toString());
    const userSubject = namedNode(PREFIXES[""] + userHash);

    writer.addQuad(
      subject,
      namedNode("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"),
      namedNode(PREFIXES.sosa + "ObservationCollection")
    );
    writer.addQuad(
      subject,
      namedNode(PREFIXES.sosa + "hasFeatureOfInterest"),
      userSubject
    );

    // Observation date
    if (log.date) {
      const dateStr = new Date(log.date).toISOString().split("T")[0];
      writer.addQuad(
        subject,
        namedNode(PREFIXES.sosa + "resultTime"),
        literal(dateStr, namedNode(PREFIXES.xsd + "date"))
      );
    }

    // === SENSOR/DEVICE INFORMATION (SSN/PROV) ===

    const sensorNode = blankNode();
    writer.addQuad(
      subject,
      namedNode(PREFIXES.prov + "wasGeneratedBy"),
      sensorNode
    );
    writer.addQuad(
      sensorNode,
      namedNode("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"),
      namedNode(PREFIXES.sosa + "Sensor")
    );
    writer.addQuad(
      sensorNode,
      namedNode(PREFIXES.rdfs + "label"),
      literal(log.deviceType || "Wearable Device")
    );

    // Device type classification
    if (log.deviceType) {
      writer.addQuad(
        sensorNode,
        namedNode(PREFIXES.ont + "deviceCategory"),
        literal(log.deviceType)
      );
    }

    // Device name/model
    if (log.nameDevice) {
      writer.addQuad(
        sensorNode,
        namedNode(PREFIXES.ont + "deviceName"),
        literal(log.nameDevice)
      );
    }

    // Platform/OS info
    if (log.sourceBundleId) {
      writer.addQuad(
        sensorNode,
        namedNode(PREFIXES.ont + "platform"),
        literal(log.sourceBundleId)
      );
    }

    // === ACTIVITY METRICS (LOINC) ===

    // Daily Steps - LOINC 55423-8
    this.addObservation(
      writer,
      subject,
      PREFIXES.loinc + "55423-8",
      log.steps,
      undefined,
      "integer"
    );

    // Total Calories Burned - LOINC 41981-2
    this.addObservation(
      writer,
      subject,
      PREFIXES.loinc + "41981-2",
      log.caloriesTotal,
      "KiloCalorie"
    );

    // Active Calories - Custom property
    if (log.caloriesActive) {
      this.addObservation(
        writer,
        subject,
        PREFIXES.ont + "activeCalories",
        log.caloriesActive,
        "KiloCalorie"
      );
    }

    // === SLEEP METRICS (SNOMED) ===

    // Sleep Duration - SNOMED 248263006
    if (log.sleepDuration !== undefined) {
      this.addObservation(
        writer,
        subject,
        PREFIXES.snomed + "248263006",
        log.sleepDuration,
        "Minute",
        "integer"
      );
    }

    // Sleep Quality - Custom property
    if (log.sleepQuality) {
      this.addObservation(
        writer,
        subject,
        PREFIXES.ont + "sleepQuality",
        log.sleepQuality,
        "Scale",
        "integer"
      );
    }

    // === HEART RATE METRICS (SNOMED) ===

    // Average Heart Rate - SNOMED 364075005
    if (log.heartRateAvg !== undefined) {
      this.addObservation(
        writer,
        subject,
        PREFIXES.snomed + "364075005",
        log.heartRateAvg,
        "BeatsPerMinute",
        "integer"
      );
    }

    // Maximum Heart Rate - Custom property
    if (log.heartRateMax !== undefined) {
      this.addObservation(
        writer,
        subject,
        PREFIXES.ont + "maxHeartRate",
        log.heartRateMax,
        "BeatsPerMinute",
        "integer"
      );
    }

    // Heart Rate Variability - Custom property
    if (log.heartRateVariability !== undefined) {
      this.addObservation(
        writer,
        subject,
        PREFIXES.ont + "heartRateVariability",
        log.heartRateVariability,
        "MilliSecond",
        "integer"
      );
    }

    // === MOVEMENT METRICS (LOINC/Custom) ===

    // Distance Covered - LOINC 41975-4
    if (log.distance !== undefined) {
      this.addObservation(
        writer,
        subject,
        PREFIXES.loinc + "41975-4",
        log.distance,
        "Meter"
      );
    }

    // Floors Climbed - LOINC 8480-6
    if (log.floorsClimbed !== undefined) {
      this.addObservation(
        writer,
        subject,
        PREFIXES.loinc + "8480-6",
        log.floorsClimbed,
        "Count",
        "integer"
      );
    }

    // Stand Hours - Custom property
    if (log.standHours !== undefined) {
      this.addObservation(
        writer,
        subject,
        PREFIXES.ont + "standHours",
        log.standHours,
        "Hour",
        "decimal"
      );
    }

    // === STRESS METRICS (Custom) ===

    // Stress Level - Custom property
    if (log.stressLevel !== undefined) {
      this.addObservation(
        writer,
        subject,
        PREFIXES.ont + "stressLevel",
        log.stressLevel,
        "Scale",
        "integer"
      );
    }

    let rdfOutput = "";
    writer.end((error, result) => (rdfOutput = result));
    return rdfOutput;
  }

  static mapWorkoutToRDF(workout: IWorkout): string {
    const writer = this.getWriter();
    const userHash = this.hashUserId(workout.userId.toString());
    const subject = namedNode(`${PREFIXES[""]}wk_${workout._id}`);
    const userSubject = namedNode(PREFIXES[""] + userHash);

    // Type: ExerciseAction
    writer.addQuad(
      subject,
      namedNode("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"),
      namedNode(PREFIXES.schema + "ExerciseAction")
    );
    writer.addQuad(subject, namedNode(PREFIXES.schema + "agent"), userSubject);

    // === WORKOUT TIMING ===

    // Start Time
    if (workout.timeStart) {
      writer.addQuad(
        subject,
        namedNode(PREFIXES.schema + "startTime"),
        literal(
          new Date(workout.timeStart).toISOString(),
          namedNode(PREFIXES.xsd + "dateTime")
        )
      );
    }

    // Calculate End Time if duration exists
    if (workout.timeStart && workout.summary?.totalDuration) {
      const endTime = new Date(
        new Date(workout.timeStart).getTime() +
          workout.summary.totalDuration * 1000
      );
      writer.addQuad(
        subject,
        namedNode(PREFIXES.schema + "endTime"),
        literal(endTime.toISOString(), namedNode(PREFIXES.xsd + "dateTime"))
      );
    }

    // Workout Duration - LOINC 55416-8
    if (workout.summary?.totalDuration !== undefined) {
      this.addObservation(
        writer,
        subject,
        PREFIXES.loinc + "55416-8",
        workout.summary.totalDuration / 60,
        "Hour",
        "decimal"
      );
    }

    // === PERFORMANCE METRICS ===

    // Total Calories Burned - LOINC 41981-2
    if (workout.summary?.totalCalories !== undefined) {
      this.addObservation(
        writer,
        subject,
        PREFIXES.loinc + "41981-2",
        workout.summary.totalCalories,
        "KiloCalorie",
        "integer"
      );
    }

    // Average Heart Rate - SNOMED 364075005
    if (workout.summary?.heartRateAvgAllWorkout !== undefined) {
      this.addObservation(
        writer,
        subject,
        PREFIXES.snomed + "364075005",
        workout.summary.heartRateAvgAllWorkout,
        "BeatsPerMinute",
        "integer"
      );
    }

    // Maximum Heart Rate - Custom property
    if (workout.summary?.heartRateMaxAllWorkout !== undefined) {
      this.addObservation(
        writer,
        subject,
        PREFIXES.ont + "maxHeartRate",
        workout.summary.heartRateMaxAllWorkout,
        "BeatsPerMinute",
        "integer"
      );
    }

    // Total Distance - LOINC 41975-4
    if (workout.summary?.totalDistance !== undefined) {
      this.addObservation(
        writer,
        subject,
        PREFIXES.loinc + "41975-4",
        workout.summary.totalDistance,
        "Meter",
        "decimal"
      );
    }

    // Total Volume - Custom property (weight × reps)
    if (
      workout.summary?.totalWeight !== undefined &&
      workout.summary?.totalReps !== undefined
    ) {
      const totalVolume =
        workout.summary.totalWeight * workout.summary.totalReps;
      this.addObservation(
        writer,
        subject,
        PREFIXES.ont + "totalVolume",
        totalVolume,
        "KiloGM",
        "decimal"
      );
    }

    // === STRENGTH METRICS ===

    // Total Sets - Custom property
    if (workout.summary?.totalSets !== undefined) {
      this.addObservation(
        writer,
        subject,
        PREFIXES.ont + "totalSets",
        workout.summary.totalSets,
        "Count",
        "integer"
      );
    }

    // Total Repetitions - Custom property
    if (workout.summary?.totalReps !== undefined) {
      this.addObservation(
        writer,
        subject,
        PREFIXES.ont + "totalReps",
        workout.summary.totalReps,
        "Count",
        "integer"
      );
    }

    // Total Weight Lifted - Custom property
    if (workout.summary?.totalWeight !== undefined) {
      this.addObservation(
        writer,
        subject,
        PREFIXES.ont + "totalWeight",
        workout.summary.totalWeight,
        "KiloGM",
        "decimal"
      );
    }

    // Average Weight - Custom property
    if (
      workout.summary?.totalWeight !== undefined &&
      workout.summary?.totalSets !== undefined &&
      workout.summary.totalSets > 0
    ) {
      const avgWeight = workout.summary.totalWeight / workout.summary.totalSets;
      this.addObservation(
        writer,
        subject,
        PREFIXES.ont + "averageWeight",
        avgWeight,
        "KiloGM",
        "decimal"
      );
    }

    // === WORKOUT NOTES ===

    if (workout.notes) {
      writer.addQuad(
        subject,
        namedNode(PREFIXES.schema + "description"),
        literal(workout.notes)
      );
    }

    // === DETAILED EXERCISES ===

    if (workout.workoutDetail && workout.workoutDetail.length > 0) {
      workout.workoutDetail.forEach((detail, detailIndex) => {
        const exerciseSessionNode = `${subject}_exercise_${detailIndex}`;
        const instrumentNode = blankNode();

        writer.addQuad(
          subject,
          namedNode(PREFIXES.schema + "instrument"),
          instrumentNode
        );
        writer.addQuad(
          instrumentNode,
          namedNode("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"),
          namedNode(PREFIXES.ont + "ExerciseSession")
        );

        // Exercise ID reference
        writer.addQuad(
          instrumentNode,
          namedNode(PREFIXES.ont + "exerciseId"),
          literal(detail.exerciseId.toString())
        );

        // Exercise Duration - LOINC 55416-8
        if (detail.durationMin !== undefined) {
          this.addObservation(
            writer,
            instrumentNode,
            PREFIXES.loinc + "55416-8",
            detail.durationMin,
            "Minute",
            "decimal"
          );
        }

        // Exercise Type - Custom property
        if (detail.type) {
          writer.addQuad(
            instrumentNode,
            namedNode(PREFIXES.ont + "exerciseType"),
            literal(detail.type)
          );
        }

        // Exercise Name (if populated)
        // This would need to be populated from exercise data or passed as parameter
        // writer.addQuad(
        //   instrumentNode,
        //   namedNode(PREFIXES.schema + "name"),
        //   literal(exerciseName)
        // );

        // === EXERCISE SETS ===

        if (detail.sets && detail.sets.length > 0) {
          // Sort sets by order to ensure correct sequence
          const sortedSets = detail.sets.sort(
            (a, b) => (a.setOrder || 0) - (b.setOrder || 0)
          );

          sortedSets.forEach((set, setIndex) => {
            const setNode = blankNode();
            const setUri = `${instrumentNode}_set_${setIndex}`;

            writer.addQuad(
              instrumentNode,
              namedNode(PREFIXES.ont + "hasSet"),
              setNode
            );
            writer.addQuad(
              setNode,
              namedNode("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"),
              namedNode(PREFIXES.ont + "Set")
            );

            // Repetitions - Custom property
            if (set.reps !== undefined) {
              this.addObservation(
                writer,
                setNode,
                PREFIXES.ont + "reps",
                set.reps,
                undefined,
                "integer"
              );
            }

            // Weight - Custom property with unit
            if (set.weight !== undefined) {
              this.addObservation(
                writer,
                setNode,
                PREFIXES.ont + "weight",
                set.weight,
                "KiloGM"
              );
            }

            // Duration - Custom property
            if (set.duration !== undefined) {
              this.addObservation(
                writer,
                setNode,
                PREFIXES.ont + "duration",
                set.duration,
                "Second",
                "integer"
              );
            }

            // Distance - Custom property
            if (set.distance !== undefined) {
              this.addObservation(
                writer,
                setNode,
                PREFIXES.ont + "distance",
                set.distance,
                "Meter",
                "decimal"
              );
            }

            // Rest Time - Custom property
            if (set.restAfterSetSeconds !== undefined) {
              this.addObservation(
                writer,
                setNode,
                PREFIXES.ont + "restTime",
                set.restAfterSetSeconds,
                "Second",
                "integer"
              );
            }

            // Set Order - Custom property
            if (set.setOrder !== undefined) {
              this.addObservation(
                writer,
                setNode,
                PREFIXES.ont + "order",
                set.setOrder,
                undefined,
                "integer"
              );
            }

            // Completion Status - Custom property
            if (set.done !== undefined) {
              this.addObservation(
                writer,
                setNode,
                PREFIXES.ont + "completed",
                set.done,
                undefined,
                "boolean"
              );
            }

            // Set Notes - Custom property
            if (set.notes) {
              writer.addQuad(
                setNode,
                namedNode(PREFIXES.schema + "description"),
                literal(set.notes)
              );
            }

            // Calculate One-Rep Max (1RM) estimation - Custom property
            if (set.weight && set.reps && set.reps <= 6) {
              // Using Brzycki formula: 1RM = weight × (36 / (37 - reps))
              const estimatedOneRM = set.weight * (36 / (37 - set.reps));
              this.addObservation(
                writer,
                setNode,
                PREFIXES.ont + "estimatedOneRM",
                Math.round(estimatedOneRM),
                "KiloGM"
              );
            }
          });

          // Exercise Summary Metrics
          const completedSets = detail.sets.filter((set) => set.done).length;
          const totalReps = detail.sets.reduce(
            (sum, set) => sum + (set.reps || 0),
            0
          );
          const totalWeight = detail.sets.reduce(
            (sum, set) => sum + (set.weight || 0),
            0
          );
          const avgWeight = completedSets > 0 ? totalWeight / completedSets : 0;

          // Exercise Volume - Custom property
          if (totalWeight && totalReps) {
            const exerciseVolume = totalWeight * totalReps;
            this.addObservation(
              writer,
              instrumentNode,
              PREFIXES.ont + "exerciseVolume",
              exerciseVolume,
              "KiloGM"
            );
          }

          // Average Set Weight - Custom property
          if (avgWeight > 0) {
            this.addObservation(
              writer,
              instrumentNode,
              PREFIXES.ont + "averageWeight",
              avgWeight,
              "KiloGM"
            );
          }

          // Total Repetitions - Custom property
          if (totalReps > 0) {
            this.addObservation(
              writer,
              instrumentNode,
              PREFIXES.ont + "totalReps",
              totalReps,
              undefined,
              "integer"
            );
          }

          // Completed Sets - Custom property
          if (completedSets > 0) {
            this.addObservation(
              writer,
              instrumentNode,
              PREFIXES.ont + "completedSets",
              completedSets,
              undefined,
              "integer"
            );
          }
        }

        // === EXERCISE DEVICE DATA ===

        if (detail.deviceData) {
          // Average Heart Rate - SNOMED 364075005
          if (detail.deviceData.heartRateAvg !== undefined) {
            this.addObservation(
              writer,
              instrumentNode,
              PREFIXES.snomed + "364075005",
              detail.deviceData.heartRateAvg,
              "BeatsPerMinute",
              "integer"
            );
          }

          // Maximum Heart Rate - Custom property
          if (detail.deviceData.heartRateMax !== undefined) {
            this.addObservation(
              writer,
              instrumentNode,
              PREFIXES.ont + "maxHeartRate",
              detail.deviceData.heartRateMax,
              "BeatsPerMinute",
              "integer"
            );
          }

          // Calories Burned - LOINC 41981-2
          if (detail.deviceData.caloriesBurned !== undefined) {
            this.addObservation(
              writer,
              instrumentNode,
              PREFIXES.loinc + "41981-2",
              detail.deviceData.caloriesBurned,
              "KiloCalorie"
            );
          }

          // Exercise Intensity Zone - Custom property
          if (
            detail.deviceData.heartRateAvg &&
            detail.deviceData.heartRateMax
          ) {
            const intensityZone = this.calculateIntensityZone(
              detail.deviceData.heartRateAvg,
              detail.deviceData.heartRateMax
            );
            writer.addQuad(
              instrumentNode,
              namedNode(PREFIXES.ont + "intensityZone"),
              literal(intensityZone)
            );
          }
        }
      });
    }

    let rdfOutput = "";
    writer.end((error, result) => (rdfOutput = result));
    return rdfOutput;
  }

  // Helper to calculate heart rate intensity zone
  private static calculateIntensityZone(avgHR: number, maxHR: number): string {
    const threshold = (maxHR - avgHR) * 0.6 + avgHR; // 60% of HR reserve
    if (threshold < 110) return "Recovery";
    if (threshold < 130) return "Aerobic";
    if (threshold < 150) return "Lactate";
    return "Anaerobic";
  }

  static mapGoalToRDF(goal: IGoal): string {
    const writer = this.getWriter();
    const subject = namedNode(`${PREFIXES[""]}gl_${goal._id}`);

    writer.addQuad(
      subject,
      namedNode("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"),
      namedNode(PREFIXES.fhir + "Goal")
    );

    // Subject Reference
    const subjectNode = blankNode();
    writer.addQuad(
      subject,
      namedNode(PREFIXES.fhir + "Goal.subject"),
      subjectNode
    );
    writer.addQuad(
      subjectNode,
      namedNode(PREFIXES.fhir + "Reference.reference"),
      literal(`User/${goal.userId}`)
    );

    // Description (Goal Type)
    const descNode = blankNode();
    writer.addQuad(
      subject,
      namedNode(PREFIXES.fhir + "Goal.description"),
      descNode
    );
    writer.addQuad(
      descNode,
      namedNode(PREFIXES.fhir + "value"),
      literal(goal.goalType)
    );

    // Start Date
    if (goal.startDate) {
      const startDateNode = blankNode();
      writer.addQuad(
        subject,
        namedNode(PREFIXES.fhir + "Goal.startDate"),
        startDateNode
      );
      const dateStr = new Date(goal.startDate).toISOString().split("T")[0];
      writer.addQuad(
        startDateNode,
        namedNode(PREFIXES.fhir + "value"),
        literal(dateStr, namedNode(PREFIXES.xsd + "date"))
      );
    }

    // Targets
    if (goal.targetMetric && goal.targetMetric.length > 0) {
      goal.targetMetric.forEach((target) => {
        const targetNode = blankNode();
        writer.addQuad(
          subject,
          namedNode(PREFIXES.fhir + "Goal.target"),
          targetNode
        );

        // Measure (Coding)
        const measureNode = blankNode();
        writer.addQuad(
          targetNode,
          namedNode(PREFIXES.fhir + "Goal.target.measure"),
          measureNode
        );
        const codingNode = blankNode();
        writer.addQuad(
          measureNode,
          namedNode(PREFIXES.fhir + "CodeableConcept.coding"),
          codingNode
        );
        writer.addQuad(
          codingNode,
          namedNode(PREFIXES.fhir + "Coding.system"),
          namedNode("http://loinc.org")
        );
        // Simple mapping for demo, real world would need a map from metricName to LOINC
        writer.addQuad(
          codingNode,
          namedNode(PREFIXES.fhir + "Coding.code"),
          literal(target.metricName)
        );

        // Quantity
        const qtyNode = blankNode();
        writer.addQuad(
          targetNode,
          namedNode(PREFIXES.fhir + "Goal.target.detailQuantity"),
          qtyNode
        );
        writer.addQuad(
          qtyNode,
          namedNode(PREFIXES.fhir + "Quantity.value"),
          literal(target.value.toString(), namedNode(PREFIXES.xsd + "decimal"))
        );
        if (target.unit) {
          writer.addQuad(
            qtyNode,
            namedNode(PREFIXES.fhir + "Quantity.unit"),
            literal(target.unit)
          );
        }
      });
    }

    let rdfOutput = "";
    writer.end((error, result) => (rdfOutput = result));
    return rdfOutput;
  }

  static mapExerciseToRDF(exercise: IExercise): string {
    const writer = this.getWriter();
    const subject = namedNode(`${PREFIXES[""]}ex_${exercise._id}`);

    writer.addQuad(
      subject,
      namedNode("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"),
      namedNode(PREFIXES.ont + "Exercise")
    );

    writer.addQuad(
      subject,
      namedNode(PREFIXES.ont + "exerciseId"),
      literal(exercise._id.toString())
    );

    writer.addQuad(
      subject,
      namedNode(PREFIXES.schema + "name"),
      literal(exercise.name)
    );

    let rdfOutput = "";
    writer.end((error, result) => (rdfOutput = result));
    return rdfOutput;
  }
}
