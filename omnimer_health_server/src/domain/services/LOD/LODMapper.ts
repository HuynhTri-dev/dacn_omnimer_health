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
  ":": "http://omnimer.health/data/",
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
    return `${PREFIXES[":"]}user_${userId}`;
  }

  static mapUserToRDF(user: IUser): string {
    if (!user.isDataSharingAccepted) return "";

    const writer = this.getWriter();
    const subject = namedNode(this.getUserURI(user._id.toString()));

    writer.addQuad(
      subject,
      namedNode(PREFIXES.schema + "Person"),
      namedNode(PREFIXES.schema + "Thing") // Implicit type, but using Person as primary
    );
    writer.addQuad(
      subject,
      namedNode("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"),
      namedNode(PREFIXES.schema + "Person")
    );

    // Gender
    if (user.gender) {
      writer.addQuad(
        subject,
        namedNode(PREFIXES.schema + "gender"),
        namedNode(PREFIXES.schema + user.gender)
      );
    }

    // Year of Birth
    if (user.birthday) {
      const year = new Date(user.birthday).getFullYear().toString();
      writer.addQuad(
        subject,
        namedNode(PREFIXES.schema + "birthDate"),
        literal(year, namedNode(PREFIXES.xsd + "gYear"))
      );
    }

    // Consent
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
    const subject = namedNode(`${PREFIXES[":"]}hp_${profile._id}`);
    const userSubject = namedNode(this.getUserURI(profile.userId.toString()));

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

    // Helper to add observation member
    const addMember = (
      property: string,
      value: any,
      unit?: string,
      type: string = "decimal"
    ) => {
      if (value === undefined || value === null) return;

      const memberNode = blankNode();
      writer.addQuad(
        subject,
        namedNode(PREFIXES.sosa + "hasMember"),
        memberNode
      );
      writer.addQuad(
        memberNode,
        namedNode("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"),
        namedNode(PREFIXES.sosa + "Observation")
      );
      writer.addQuad(
        memberNode,
        namedNode(PREFIXES.sosa + "observedProperty"),
        namedNode(property)
      );
      writer.addQuad(
        memberNode,
        namedNode(PREFIXES.sosa + "hasSimpleResult"),
        literal(value.toString(), namedNode(PREFIXES.xsd + type))
      );
      if (unit) {
        writer.addQuad(
          memberNode,
          namedNode(PREFIXES.sosa + "hasResultUnit"),
          namedNode(PREFIXES.unit + unit)
        );
      }
    };

    // BMI - LOINC 39156-5
    addMember(PREFIXES.loinc + "39156-5", profile.bmi, "KiloGM-M2");

    // Body Fat - LOINC 41982-0
    addMember(PREFIXES.loinc + "41982-0", profile.bodyFatPercentage, "Percent");

    // Resting Heart Rate - SNOMED 364075005
    addMember(
      PREFIXES.snomed + "364075005",
      profile.restingHeartRate,
      "BeatsPerMinute",
      "integer"
    );

    // Weight - LOINC 29463-7
    addMember(PREFIXES.loinc + "29463-7", profile.weight, "KiloGM");

    // Height - LOINC 8302-2
    addMember(PREFIXES.loinc + "8302-2", profile.height, "CentiM");

    let rdfOutput = "";
    writer.end((error, result) => (rdfOutput = result));
    return rdfOutput;
  }

  static mapWatchLogToRDF(log: IWatchLog): string {
    const writer = this.getWriter();
    const subject = namedNode(`${PREFIXES[":"]}wl_${log._id}`);
    const userSubject = namedNode(this.getUserURI(log.userId.toString()));

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

    if (log.date) {
      const dateStr = new Date(log.date).toISOString().split("T")[0];
      writer.addQuad(
        subject,
        namedNode(PREFIXES.sosa + "resultTime"),
        literal(dateStr, namedNode(PREFIXES.xsd + "date"))
      );
    }

    // Sensor/Device info
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
      literal(log.deviceType)
    );
    if (log.nameDevice) {
      writer.addQuad(
        sensorNode,
        namedNode(PREFIXES.ont + "deviceType"),
        literal(log.nameDevice)
      );
    }

    const addMember = (
      property: string,
      value: any,
      unit?: string,
      type: string = "decimal"
    ) => {
      if (value === undefined || value === null) return;

      const memberNode = blankNode();
      writer.addQuad(
        subject,
        namedNode(PREFIXES.sosa + "hasMember"),
        memberNode
      );
      writer.addQuad(
        memberNode,
        namedNode("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"),
        namedNode(PREFIXES.sosa + "Observation")
      );
      writer.addQuad(
        memberNode,
        namedNode(PREFIXES.sosa + "observedProperty"),
        namedNode(property)
      );
      writer.addQuad(
        memberNode,
        namedNode(PREFIXES.sosa + "hasSimpleResult"),
        literal(value.toString(), namedNode(PREFIXES.xsd + type))
      );
      if (unit) {
        writer.addQuad(
          memberNode,
          namedNode(PREFIXES.sosa + "hasResultUnit"),
          namedNode(PREFIXES.unit + unit)
        );
      }
    };

    // Steps - LOINC 55423-8
    addMember(PREFIXES.loinc + "55423-8", log.steps, undefined, "integer");

    // Calories Burned - LOINC 41981-2
    addMember(PREFIXES.loinc + "41981-2", log.caloriesTotal, "KiloCalorie");

    // Sleep Duration - SNOMED 248263006
    addMember(
      PREFIXES.snomed + "248263006",
      log.sleepDuration,
      "Minute",
      "integer"
    );

    // Heart Rate Avg - SNOMED 364075005
    addMember(
      PREFIXES.snomed + "364075005",
      log.heartRateAvg,
      "BeatsPerMinute",
      "integer"
    );

    let rdfOutput = "";
    writer.end((error, result) => (rdfOutput = result));
    return rdfOutput;
  }

  static mapWorkoutToRDF(workout: IWorkout): string {
    const writer = this.getWriter();
    const subject = namedNode(`${PREFIXES[":"]}wk_${workout._id}`);
    const userSubject = namedNode(this.getUserURI(workout.userId.toString()));

    writer.addQuad(
      subject,
      namedNode("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"),
      namedNode(PREFIXES.schema + "ExerciseAction")
    );
    writer.addQuad(subject, namedNode(PREFIXES.schema + "agent"), userSubject);

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

    // Summary Stats
    if (workout.summary?.totalCalories) {
      writer.addQuad(
        subject,
        namedNode(PREFIXES.ont + "totalCalories"),
        literal(
          workout.summary.totalCalories.toString(),
          namedNode(PREFIXES.xsd + "integer")
        )
      );
    }
    if (workout.summary?.heartRateAvgAllWorkout) {
      writer.addQuad(
        subject,
        namedNode(PREFIXES.ont + "avgHeartRate"),
        literal(
          workout.summary.heartRateAvgAllWorkout.toString(),
          namedNode(PREFIXES.xsd + "integer")
        )
      );
    }

    // Detailed Exercises
    if (workout.workoutDetail && workout.workoutDetail.length > 0) {
      workout.workoutDetail.forEach((detail) => {
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

        // Assuming we might not have the exercise name populated here, using ID for now or if populate was called.
        // Ideally, we should pass the exercise name or fetch it. For now, using ID as a fallback or assuming it's populated if type is any.
        // Since the interface says exerciseId is ObjectId, we'll just use that as a string identifier.
        writer.addQuad(
          instrumentNode,
          namedNode(PREFIXES.ont + "exerciseId"),
          literal(detail.exerciseId.toString())
        );

        if (detail.sets && detail.sets.length > 0) {
          detail.sets.forEach((set) => {
            const setNode = blankNode();
            writer.addQuad(
              instrumentNode,
              namedNode(PREFIXES.ont + "sets"),
              setNode
            );
            writer.addQuad(
              setNode,
              namedNode("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"),
              namedNode(PREFIXES.ont + "Set")
            );

            if (set.reps)
              writer.addQuad(
                setNode,
                namedNode(PREFIXES.ont + "reps"),
                literal(
                  set.reps.toString(),
                  namedNode(PREFIXES.xsd + "integer")
                )
              );
            if (set.weight)
              writer.addQuad(
                setNode,
                namedNode(PREFIXES.ont + "weight"),
                literal(
                  set.weight.toString(),
                  namedNode(PREFIXES.xsd + "decimal")
                )
              );
            writer.addQuad(
              setNode,
              namedNode(PREFIXES.ont + "order"),
              literal(
                set.setOrder.toString(),
                namedNode(PREFIXES.xsd + "integer")
              )
            );
          });
        }
      });
    }

    let rdfOutput = "";
    writer.end((error, result) => (rdfOutput = result));
    return rdfOutput;
  }

  static mapGoalToRDF(goal: IGoal): string {
    const writer = this.getWriter();
    const subject = namedNode(`${PREFIXES[":"]}gl_${goal._id}`);

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
    const subject = namedNode(`${PREFIXES[":"]}ex_${exercise._id}`);

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
