// File: src/seeding/seedExercise.ts

import * as fs from "fs";
import * as path from "path";
import { Types } from "mongoose";
import {
  Exercise,
  IExercise,
  IMuscle,
  IExerciseCategory,
  IExerciseType,
  IEquipment,
} from "../domain/models";
import { uploadToCloudflare } from "../utils/CloudflareUpload";
// [Bổ sung] Import MATCHING_EXERCISES từ matchExercise.ts
import { MATCHING_EXERCISES } from "./matchExercise"; // Giả định đường dẫn tương đối

// Đường dẫn tuyệt đối đến thư mục gốc chứa JSON và ảnh
const EXERCISES_ROOT_DIR = path.resolve(__dirname, "../../../exercises");

/**
 * Interface cho dữ liệu JSON exercise
 */
export interface IExerciseJson {
  id: string;
  name: string;
  force?: "pull" | "push" | "static" | "other" | "";
  level: "beginner" | "intermediate" | "expert";
  mechanic?: "compound" | "isolation" | "other" | "";
  equipment: string | null;
  primaryMuscles: string[];
  secondaryMuscles: string[];
  instructions: string[];
  category: string;
  images: string[];
}

/**
 * Định nghĩa kiểu cho bản đồ Name -> ObjectId
 */
interface NameIdMap {
  [name: string]: Types.ObjectId;
}

/**
 * Định nghĩa kiểu cho bản đồ Muscle Name -> Document (chứa BodyPartIds)
 */
interface MuscleDocMap {
  [name: string]: { _id: Types.ObjectId; bodyPartIds: Types.ObjectId[] };
}

/**
 * Chuyển chuỗi sang Title Case
 */
function toTitleCase(str: string): string {
  if (!str) return str;
  return str
    .toLowerCase()
    .split(" ")
    .map((word) => word.charAt(0).toUpperCase() + word.slice(1))
    .join(" ");
}

/**
 * Tạo bản đồ Name -> ObjectId từ mảng documents
 */
function createNameIdMap<T extends { name: string; _id: Types.ObjectId }>(
  docs: T[]
): NameIdMap {
  const map: NameIdMap = {};
  docs.forEach((doc) => {
    map[doc.name] = doc._id;
  });
  return map;
}

/**
 * Tạo bản đồ Muscle với bodyPartIds
 */
function createMuscleDocMap(docs: IMuscle[]): MuscleDocMap {
  const map: MuscleDocMap = {};
  docs.forEach((doc) => {
    map[doc.name] = {
      _id: doc._id,
      bodyPartIds: Array.isArray(doc.bodyPartIds) ? doc.bodyPartIds : [],
    };
  });
  return map;
}

/**
 * Đọc tất cả file JSON từ thư mục exercises
 */
function getAllJsonFiles(dirPath: string): string[] {
  try {
    const files = fs.readdirSync(dirPath);
    return files.filter((file) => file.endsWith(".json"));
  } catch (error) {
    console.error(`Lỗi khi đọc thư mục ${dirPath}:`, error);
    return [];
  }
}

/**
 * Đọc và parse file JSON exercise
 */
function readExerciseJsonFile(filename: string): IExerciseJson | null {
  const filePath = path.join(EXERCISES_ROOT_DIR, filename);
  try {
    const fileContent = fs.readFileSync(filePath, "utf-8");
    const jsonData = JSON.parse(fileContent) as IExerciseJson;
    return jsonData;
  } catch (error) {
    console.error(`Lỗi: Không thể đọc file JSON ${filePath}.`, error);
    return null;
  }
}

/**
 * Đọc file ảnh từ đường dẫn và chuyển thành Express.Multer.File
 */
function readImageFileToMulterFile(
  imagePath: string
): Express.Multer.File | null {
  const fullPath = path.join(EXERCISES_ROOT_DIR, imagePath);
  try {
    if (!fs.existsSync(fullPath)) {
      console.warn(`[Cảnh báo] Không tìm thấy file ảnh: ${fullPath}`);
      return null;
    }

    const buffer = fs.readFileSync(fullPath);
    const filename = path.basename(imagePath);
    const fileExtension = path.extname(filename).toLowerCase();

    let mimetype = "application/octet-stream";
    if (fileExtension === ".jpg" || fileExtension === ".jpeg") {
      mimetype = "image/jpeg";
    } else if (fileExtension === ".png") {
      mimetype = "image/png";
    } else if (fileExtension === ".gif") {
      mimetype = "image/gif";
    } else if (fileExtension === ".webp") {
      mimetype = "image/webp";
    }

    // Tạo đối tượng Express.Multer.File
    return {
      fieldname: "image",
      originalname: filename,
      encoding: "7bit",
      mimetype: mimetype,
      buffer: buffer,
      size: buffer.length,
    } as Express.Multer.File;
  } catch (error) {
    console.warn(
      `[Cảnh báo Upload] Không thể đọc file ảnh: ${fullPath}`,
      error
    );
    return null;
  }
}

/**
 * Tìm Equipment ID phù hợp dựa trên tên equipment từ JSON
 */
function findEquipmentId(
  equipmentName: string | null,
  equipmentMap: NameIdMap
): Types.ObjectId | null {
  if (!equipmentName) return null;

  const titleCase = toTitleCase(equipmentName);

  // Thử khớp chính xác
  if (equipmentMap[titleCase]) {
    return equipmentMap[titleCase];
  }

  // Thử một số mapping phổ biến
  const mappings: { [key: string]: string } = {
    "body only": "Body Only",
    bodyweight: "Body Only",
    barbell: "Barbell",
    dumbbell: "Dumbbell",
    cable: "Cable",
    machine: "Machine",
    kettlebell: "Kettlebell",
    bands: "Bands",
    "medicine ball": "Medicine Ball",
    "exercise ball": "Exercise Ball",
    "foam roll": "Foam Roll",
    "e-z curl bar": "E-Z Curl Bar",
  };

  const normalized = equipmentName.toLowerCase();
  for (const [key, value] of Object.entries(mappings)) {
    if (normalized.includes(key) && equipmentMap[value]) {
      return equipmentMap[value];
    }
  }

  return null;
}

/**
 * Tìm Category ID phù hợp dựa trên tên category từ JSON
 */
function findCategoryId(
  categoryName: string,
  categoryMap: NameIdMap
): Types.ObjectId | null {
  const titleCase = toTitleCase(categoryName);

  if (categoryMap[titleCase]) {
    return categoryMap[titleCase];
  }

  // Mapping phổ biến
  const mappings: { [key: string]: string } = {
    strength: "Strength",
    cardio: "Cardio",
    stretching: "Stretching",
    powerlifting: "Powerlifting",
    strongman: "Strongman",
    "olympic weightlifting": "Olympic Weightlifting",
    plyometrics: "Plyometrics",
  };

  const normalized = categoryName.toLowerCase();
  if (mappings[normalized] && categoryMap[mappings[normalized]]) {
    return categoryMap[mappings[normalized]];
  }

  return null;
}

/**
 * Tìm Exercise Type ID dựa trên category
 */
function findExerciseTypeId(
  categoryName: string,
  typeMap: NameIdMap
): Types.ObjectId | null {
  const titleCase = toTitleCase(categoryName);

  // Mapping category sang type
  const mappings: { [key: string]: string } = {
    strength: "Strength Training",
    cardio: "Cardio",
    stretching: "Flexibility",
    powerlifting: "Strength Training",
    strongman: "Strength Training",
    "olympic weightlifting": "Strength Training",
    plyometrics: "Cardio",
  };

  const normalized = categoryName.toLowerCase();
  const typeName = mappings[normalized] || titleCase;

  return typeMap[typeName] || null;
}

/**
 * Hàm chính để seed dữ liệu Bài tập
 */
export async function seedExercises(
  categoryDocs: IExerciseCategory[],
  typeDocs: IExerciseType[],
  equipmentDocs: IEquipment[],
  muscleDocs: IMuscle[]
) {
  console.log("=== BẮT ĐẦU SEED EXERCISES ===");

  // Xóa dữ liệu cũ
  await Exercise.deleteMany({});
  console.log("Đã xóa dữ liệu Exercise cũ");

  // Chuẩn bị bản đồ ID để tra cứu nhanh
  const equipmentMap = createNameIdMap(equipmentDocs);
  const categoryMap = createNameIdMap(categoryDocs);
  const typeMap = createNameIdMap(typeDocs);
  const muscleDocMap = createMuscleDocMap(muscleDocs);

  console.log(`Equipment Map: ${Object.keys(equipmentMap).length} items`);
  console.log(`Category Map: ${Object.keys(categoryMap).length} items`);
  console.log(`Type Map: ${Object.keys(typeMap).length} items`);
  console.log(`Muscle Map: ${Object.keys(muscleDocMap).length} items`);

  // 1. Lấy danh sách file JSON ưu tiên từ MATCHING_EXERCISES
  const prioritizedJsonFiles = MATCHING_EXERCISES.map(
    (item: any) => item.jsonFile
  );
  const prioritizedSet = new Set(prioritizedJsonFiles);
  console.log(
    `Tìm thấy ${prioritizedJsonFiles.length} file JSON ưu tiên từ matchExercise.ts`
  );

  // 2. Lấy tất cả file JSON từ thư mục exercises
  const allJsonFilesInDir = getAllJsonFiles(EXERCISES_ROOT_DIR);

  // 3. Lọc ra các file CHƯA CÓ trong danh sách ưu tiên
  const nonPrioritizedJsonFiles = allJsonFilesInDir.filter(
    (filename) => !prioritizedSet.has(filename)
  );

  // 4. Chọn thêm 30 file ngẫu nhiên (hoặc tất cả nếu ít hơn 30)
  const additionalFilesCount = 30;
  const additionalFiles = nonPrioritizedJsonFiles.slice(
    0,
    Math.min(additionalFilesCount, nonPrioritizedJsonFiles.length)
  );
  console.log(
    `Tìm thấy ${allJsonFilesInDir.length} file JSON trong thư mục exercises.`
  );
  console.log(`Sẽ bổ sung thêm ${additionalFiles.length} file JSON.`);

  // 5. Kết hợp danh sách (Ưu tiên trước, bổ sung sau)
  const jsonFilesToProcess = [...prioritizedJsonFiles, ...additionalFiles];
  console.log(`Tổng cộng sẽ xử lý ${jsonFilesToProcess.length} file JSON.`);

  if (jsonFilesToProcess.length === 0) {
    console.warn("Không tìm thấy file JSON nào để seed!");
    return [];
  }

  const exercisesToInsert: Partial<IExercise>[] = [];
  const R2_FOLDER = "exercises/images";

  // Xử lý từng file JSON
  for (let i = 0; i < jsonFilesToProcess.length; i++) {
    const filename = jsonFilesToProcess[i];
    const isPrioritized = prioritizedSet.has(filename);

    console.log(
      `\n[${i + 1}/${jsonFilesToProcess.length}] Xử lý: ${filename} ${
        isPrioritized ? "(Ưu tiên)" : "(Bổ sung)"
      }`
    );

    const jsonData = readExerciseJsonFile(filename);
    if (!jsonData) {
      console.warn(`  ⚠️ Bỏ qua - Không đọc được JSON`);
      continue;
    }

    try {
      // 1. Tìm Equipment ID
      const equipmentId = findEquipmentId(jsonData.equipment, equipmentMap);
      if (!equipmentId) {
        console.warn(
          `  ⚠️ Bỏ qua - Không tìm thấy Equipment: ${jsonData.equipment}`
        );
        continue;
      }

      // 2. Tìm Category ID
      const categoryId = findCategoryId(jsonData.category, categoryMap);
      if (!categoryId) {
        console.warn(
          `  ⚠️ Bỏ qua - Không tìm thấy Category: ${jsonData.category}`
        );
        continue;
      }

      // 3. Tìm Exercise Type ID
      const typeId = findExerciseTypeId(jsonData.category, typeMap);
      const exerciseTypeIds = typeId ? [typeId] : [];

      // 4. Xử lý Muscles (Primary & Secondary) và thu thập BodyPart IDs
      const bodyPartIdSet = new Set<Types.ObjectId>();
      const mainMuscleIds: Types.ObjectId[] = [];
      const secondaryMuscleIds: Types.ObjectId[] = [];

      // Xử lý Primary Muscles
      for (const mName of jsonData.primaryMuscles || []) {
        const titleCaseMName = toTitleCase(mName);
        const muscleDoc = muscleDocMap[titleCaseMName];
        if (muscleDoc) {
          mainMuscleIds.push(muscleDoc._id);
          muscleDoc.bodyPartIds.forEach((bpId) => bodyPartIdSet.add(bpId));
        } else {
          console.warn(
            `    ⚠️ Không tìm thấy Primary Muscle: ${titleCaseMName}`
          );
        }
      }

      // Xử lý Secondary Muscles
      for (const mName of jsonData.secondaryMuscles || []) {
        const titleCaseMName = toTitleCase(mName);
        const muscleDoc = muscleDocMap[titleCaseMName];
        if (muscleDoc) {
          secondaryMuscleIds.push(muscleDoc._id);
          // Cũng thêm bodyPart từ secondary muscles
          muscleDoc.bodyPartIds.forEach((bpId) => bodyPartIdSet.add(bpId));
        } else {
          console.warn(
            `    ⚠️ Không tìm thấy Secondary Muscle: ${titleCaseMName}`
          );
        }
      }

      const bodyPartIds = Array.from(bodyPartIdSet);
      if (bodyPartIds.length === 0) {
        console.warn(`  ⚠️ Bỏ qua - Không có BodyPart nào`);
        continue;
      }

      // 5. Upload ảnh và lấy URL
      const imageUrls: string[] = [];
      console.log(`  📸 Upload ${jsonData.images?.length || 0} ảnh...`);

      for (const imagePath of jsonData.images || []) {
        const multerFile = readImageFileToMulterFile(imagePath);

        if (multerFile) {
          try {
            const imageUrl = await uploadToCloudflare(multerFile, R2_FOLDER);
            imageUrls.push(imageUrl);
            console.log(`    ✅ Uploaded: ${imagePath}`);
          } catch (uploadError) {
            console.error(`    ❌ Lỗi upload ${imagePath}:`, uploadError);
          }
        }
      }

      // 6. Xử lý instructions - kết hợp mảng thành chuỗi với \n
      const instructions = jsonData.instructions?.join("\n") || "";

      // 7. Map difficulty level
      const difficultyMap: { [key: string]: string } = {
        beginner: "Beginner",
        intermediate: "Intermediate",
        advanced: "Advanced",
        expert: "Expert",
      };
      const difficulty =
        difficultyMap[jsonData.level.toLowerCase()] || "Beginner";

      // 8. Tạo description
      const muscleNames = (jsonData.primaryMuscles || [])
        .map(toTitleCase)
        .join(", ");
      const description = muscleNames
        ? `Bài tập tập trung vào ${muscleNames}.`
        : "Bài tập toàn thân.";

      // 9. Chuẩn bị dữ liệu để insert
      const exercise: Partial<IExercise> = {
        name: toTitleCase(jsonData.name),
        description: description,
        instructions: instructions,

        equipments: [equipmentId],
        mainMuscles: mainMuscleIds,
        secondaryMuscles: secondaryMuscleIds,
        bodyParts: bodyPartIds,
        exerciseCategories: [categoryId],
        exerciseTypes: exerciseTypeIds,

        location: "Gym" as any,
        difficulty: difficulty as any,
        imageUrls: imageUrls,
      };

      exercisesToInsert.push(exercise);
      console.log(`  ✅ Đã chuẩn bị xong`);
    } catch (error) {
      console.error(`  ❌ Lỗi xử lý ${jsonData.name}:`, error);
    }
  }

  // 10. Chèn dữ liệu vào DB
  if (exercisesToInsert.length === 0) {
    console.warn("\n⚠️ Không có bài tập nào để seed!");
    return [];
  }

  console.log(`\n📥 Đang chèn ${exercisesToInsert.length} bài tập vào DB...`);
  const docs = await Exercise.insertMany(exercisesToInsert);
  console.log(`✅ Đã seed ${docs.length} Exercises thành công!`);

  return docs;
}
