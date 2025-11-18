import { Types } from "mongoose";
// Giả định các models BodyPart, Muscle nằm trong ../domain/models
import { BodyPart, Muscle, IMuscle } from "../domain/models";

interface BodyPartIdMap {
  [name: string]: Types.ObjectId;
}

/**
 * Chuyển đổi chuỗi thành định dạng In hoa Chữ cái Đầu của Mỗi Từ.
 * Ví dụ: "lower arms" -> "Lower Arms"
 * @param str Chuỗi đầu vào
 * @returns Chuỗi đã được định dạng
 */
function toTitleCase(str: string): string {
  if (!str) return str;
  return str
    .toLowerCase()
    .split(" ")
    .map((word) => word.charAt(0).toUpperCase() + word.slice(1))
    .join(" ");
}

// ----------------------------------------------------------------------------------------------------
// --- Dữ liệu Phần Cơ Thể Tổng Quát (bodyPartsData) (Đã được chuẩn hóa và bổ sung mô tả) ---
// ----------------------------------------------------------------------------------------------------
const rawBodyPartsData: { name: string; description: string }[] = [
  { name: "neck", description: "Vùng cổ và vai trên." },
  { name: "lower arms", description: "Bao gồm cẳng tay, cổ tay và bàn tay." },
  { name: "shoulders", description: "Vùng khớp vai và cơ delta." },
  { name: "cardio", description: "Hệ thống tim mạch và hô hấp." },
  {
    name: "upper arms",
    description: "Bao gồm cơ bắp tay trước (Biceps) và bắp tay sau (Triceps).",
  },
  { name: "chest", description: "Vùng cơ ngực (Pectorals)." },
  {
    name: "lower legs",
    description: "Bao gồm cơ bắp chân, ống chân và mắt cá chân.",
  },
  {
    name: "back",
    description: "Toàn bộ vùng lưng, từ cơ thang đến lưng dưới.",
  },
  {
    name: "upper legs",
    description:
      "Bao gồm đùi trước (Quads), đùi sau (Hamstrings) và cơ mông (Glutes).",
  },
  {
    name: "waist",
    description: "Vùng eo, bao gồm cơ bụng và cơ liên sườn (Obliques).",
  },
];

// ----------------------------------------------------------------------------------------------------
// --- Dữ liệu Cơ Bắp Chi Tiết (musclesData) (Đã được chuẩn hóa và ánh xạ tới BodyPart) ---
// ----------------------------------------------------------------------------------------------------
const musclesData: {
  name: string;
  bodyPartNames: string[]; // Tên BodyPart đã được chuẩn hóa
  description: string;
}[] = [
  // Lower Legs
  {
    name: "shins",
    bodyPartNames: ["Lower Legs"],
    description: "Cơ ống chân (Tibialis Anterior).",
  },
  {
    name: "soleus",
    bodyPartNames: ["Lower Legs"],
    description: "Cơ dép (nằm dưới cơ bắp chân), quan trọng trong sức bền.",
  },
  {
    name: "calves",
    bodyPartNames: ["Lower Legs"],
    description: "Cơ bắp chân (Gastrocnemius).",
  },
  {
    name: "ankles",
    bodyPartNames: ["Lower Legs"],
    description: "Cơ/Khớp Mắt cá chân.",
  },
  {
    name: "ankle stabilizers",
    bodyPartNames: ["Lower Legs"],
    description: "Các cơ nhỏ giúp ổn định mắt cá chân.",
  },

  // Lower Arms
  { name: "hands", bodyPartNames: ["Lower Arms"], description: "Cơ Bàn tay." },
  {
    name: "grip muscles",
    bodyPartNames: ["Lower Arms"],
    description: "Các cơ dùng để nắm/kẹp.",
  },
  {
    name: "wrist extensors",
    bodyPartNames: ["Lower Arms"],
    description: "Cơ duỗi cổ tay.",
  },
  {
    name: "wrist flexors",
    bodyPartNames: ["Lower Arms"],
    description: "Cơ gập cổ tay.",
  },
  {
    name: "wrists",
    bodyPartNames: ["Lower Arms"],
    description: "Các cơ quanh cổ tay.",
  },
  {
    name: "forearms",
    bodyPartNames: ["Lower Arms"],
    description: "Cơ Cẳng tay.",
  },

  // Neck
  {
    name: "sternocleidomastoid",
    bodyPartNames: ["Neck"],
    description: "Cơ ức đòn chũm, giúp xoay và gập cổ.",
  },
  {
    name: "levator scapulae",
    bodyPartNames: ["Neck", "Shoulders", "Back"],
    description: "Cơ nâng vai.",
  },

  // Upper Legs
  {
    name: "inner thighs",
    bodyPartNames: ["Upper Legs"],
    description: "Cơ đùi trong (Adductors).",
  },
  {
    name: "quadriceps",
    bodyPartNames: ["Upper Legs"],
    description: "Cơ đùi trước.",
  },
  {
    name: "hamstrings",
    bodyPartNames: ["Upper Legs"],
    description: "Cơ đùi sau.",
  },
  { name: "glutes", bodyPartNames: ["Upper Legs"], description: "Cơ Mông." },
  {
    name: "abductors",
    bodyPartNames: ["Upper Legs"],
    description: "Cơ dạng đùi (Phần ngoài hông).",
  },
  {
    name: "adductors",
    bodyPartNames: ["Upper Legs"],
    description: "Cơ khép đùi (Phần trong đùi).",
  },
  {
    name: "hip flexors",
    bodyPartNames: ["Upper Legs", "Waist"],
    description: "Cơ gập hông.",
  },
  {
    name: "quads",
    bodyPartNames: ["Upper Legs"],
    description: "Tên viết tắt của Cơ đùi trước.",
  }, // Để đảm bảo match với dataset cũ
  {
    name: "groin",
    bodyPartNames: ["Upper Legs"],
    description: "Vùng háng, thường liên quan đến cơ khép.",
  },

  // Upper Arms
  {
    name: "brachialis",
    bodyPartNames: ["Upper Arms"],
    description: "Cơ cánh tay, nằm dưới bắp tay (Biceps).",
  },
  {
    name: "biceps",
    bodyPartNames: ["Upper Arms"],
    description: "Cơ bắp tay trước.",
  },
  {
    name: "triceps",
    bodyPartNames: ["Upper Arms"],
    description: "Cơ bắp tay sau.",
  },

  // Shoulders
  {
    name: "deltoids",
    bodyPartNames: ["Shoulders"],
    description: "Cơ Delta (Cơ vai).",
  },
  {
    name: "rotator cuff",
    bodyPartNames: ["Shoulders"],
    description: "Các cơ giúp xoay và ổn định khớp vai.",
  },
  {
    name: "rear deltoids",
    bodyPartNames: ["Shoulders", "Back"],
    description: "Cơ vai sau.",
  },
  {
    name: "delts",
    bodyPartNames: ["Shoulders"],
    description: "Tên viết tắt của Cơ Delta.",
  },

  // Chest
  {
    name: "upper chest",
    bodyPartNames: ["Chest"],
    description: "Phần trên của Cơ ngực (Clavicular head).",
  },
  {
    name: "chest",
    bodyPartNames: ["Chest"],
    description: "Cơ Ngực (Pectorals).",
  },
  {
    name: "pectorals",
    bodyPartNames: ["Chest"],
    description: "Cơ Ngực (Tên chính thức).",
  },
  {
    name: "serratus anterior",
    bodyPartNames: ["Chest", "Waist"],
    description: "Cơ răng cưa, giúp ổn định vai và hô hấp.",
  },

  // Back
  {
    name: "latissimus dorsi",
    bodyPartNames: ["Back"],
    description: "Cơ xô lớn.",
  },
  {
    name: "trapezius",
    bodyPartNames: ["Back", "Neck", "Shoulders"],
    description: "Cơ Thang.",
  },
  {
    name: "rhomboids",
    bodyPartNames: ["Back"],
    description: "Cơ trám (Lưng giữa).",
  },
  {
    name: "upper back",
    bodyPartNames: ["Back"],
    description: "Vùng lưng trên.",
  },
  {
    name: "traps",
    bodyPartNames: ["Back", "Neck"],
    description: "Tên viết tắt của Cơ Thang.",
  },
  {
    name: "lats",
    bodyPartNames: ["Back"],
    description: "Tên viết tắt của Cơ Xô.",
  },

  // Waist/Core
  {
    name: "lower abs",
    bodyPartNames: ["Waist"],
    description: "Phần dưới của Cơ bụng (thực ra là một phần của Abdominals).",
  },
  {
    name: "abdominals",
    bodyPartNames: ["Waist"],
    description: "Cơ Bụng (Rectus Abdominis).",
  },
  {
    name: "obliques",
    bodyPartNames: ["Waist"],
    description: "Cơ liên sườn (Xoay thân).",
  },
  {
    name: "lower back",
    bodyPartNames: ["Waist", "Back"],
    description: "Cơ lưng dưới (Erector Spinae).",
  },
  {
    name: "core",
    bodyPartNames: ["Waist", "Back"],
    description: "Cơ lõi (bao gồm bụng, lưng dưới, hông).",
  },
  {
    name: "abs",
    bodyPartNames: ["Waist"],
    description: "Tên viết tắt của Cơ Bụng.",
  },
  {
    name: "spine",
    bodyPartNames: ["Back", "Waist"],
    description: "Cột sống (thường là cơ ổn định cột sống).",
  },

  // Cardio & General
  {
    name: "cardiovascular system",
    bodyPartNames: ["Cardio"],
    description:
      "Hệ thống Tim mạch và hô hấp (là mục tiêu tập luyện, không phải cơ bắp giải phẫu).",
  },
  {
    name: "back",
    bodyPartNames: ["Back"],
    description:
      "Dùng để phân loại các bài tập tập trung vào vùng lưng nói chung.",
  },
  {
    name: "shoulders",
    bodyPartNames: ["Shoulders"],
    description:
      "Dùng để phân loại các bài tập tập trung vào vùng vai nói chung.",
  },
  {
    name: "feet",
    bodyPartNames: ["Lower Legs"],
    description: "Các cơ và khớp bàn chân.",
  },
];

/**
 * Thực hiện seed dữ liệu cho BodyPart và Muscle.
 * @returns Object chứa danh sách các BodyPart và Muscle đã được lưu.
 */
export async function seedBodyPartsAndMuscles() {
  // Xóa dữ liệu cũ
  await BodyPart.deleteMany({});
  await Muscle.deleteMany({});
  console.log("Dữ liệu BodyPart và Muscle cũ đã được dọn dẹp.");

  // --- A. SEED BODY PARTS ---
  // Áp dụng toTitleCase cho tên BodyPart
  const bodyPartsToInsert = rawBodyPartsData.map((item) => ({
    ...item,
    name: toTitleCase(item.name),
  }));

  const savedBodyParts = await BodyPart.insertMany(bodyPartsToInsert);
  console.log(`✅ Đã thêm ${savedBodyParts.length} BodyParts.`);

  // Tạo bản đồ ánh xạ Tên chuẩn hóa -> ID
  const bodyPartIdMap: BodyPartIdMap = {};
  savedBodyParts.forEach((part) => {
    // Lưu tên đã được TitleCase vào map
    bodyPartIdMap[part.name] = part._id;
  });

  // --- B. CHUẨN BỊ VÀ SEED MUSCLES ---
  const preparedMusclesData: Partial<IMuscle>[] = musclesData.map((muscle) => {
    const bodyPartIds: Types.ObjectId[] = [];

    // Ánh xạ tên BodyPart (đã được TitleCase) sang ObjectId
    muscle.bodyPartNames.forEach((bpName) => {
      // Chuẩn hóa tên BodyPart trong muscleData để tìm trong bodyPartIdMap
      const titleCaseBpName = toTitleCase(bpName);
      const id = bodyPartIdMap[titleCaseBpName];

      if (id) {
        bodyPartIds.push(id);
      } else {
        console.warn(
          `[Cảnh báo] Không tìm thấy BodyPart ID cho: ${titleCaseBpName} (Muscle: ${toTitleCase(
            muscle.name
          )})`
        );
      }
    });

    return {
      name: toTitleCase(muscle.name), // Áp dụng TitleCase cho tên Muscle
      bodyPartIds: bodyPartIds, // Cần đảm bảo schema Muscle của bạn có trường `bodyPartIds`
      description: muscle.description,
    };
  });

  // Kiểm tra trùng lặp tên cơ bắp trước khi chèn (nếu cần)
  const uniqueMusclesToInsert: Partial<IMuscle>[] = [];
  const muscleNames = new Set<string>();

  preparedMusclesData.forEach((muscle) => {
    if (!muscleNames.has(muscle.name!)) {
      muscleNames.add(muscle.name!);
      uniqueMusclesToInsert.push(muscle);
    }
  });

  const savedMuscles = await Muscle.insertMany(uniqueMusclesToInsert);
  console.log(`✅ Đã thêm ${savedMuscles.length} Muscles.`);

  return { savedBodyParts, savedMuscles };
}
