import { Equipment, IEquipment } from "../domain/models"; // Điều chỉnh đường dẫn đến model của bạn

/**
 * Chuyển đổi chuỗi thành định dạng In hoa Chữ cái Đầu của Mỗi Từ.
 * Ví dụ: "elliptical machine" -> "Elliptical Machine"
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

/**
 * Hàm Seeding (Gieo hạt) cho Thiết bị Tập luyện (Equipment)
 * @returns Danh sách các Equipment Document đã được tạo
 */
export async function seedEquipment() {
  // 1. Xóa tất cả các bản ghi Equipment hiện có
  await Equipment.deleteMany({});

  // 2. Danh sách các thiết bị với mô tả bổ sung
  const rawEquipmentsData = [
    {
      name: "stepmill machine",
      description:
        "Máy leo cầu thang mô phỏng hoạt động leo dốc hoặc leo cầu thang, rất tốt cho cơ mông và cơ đùi.",
    },
    {
      name: "elliptical machine",
      description:
        "Máy tập thể dục nhịp điệu không tạo ra tác động, giúp luyện tập tim mạch và toàn thân.",
    },
    {
      name: "trap bar",
      description:
        "Thanh tạ hình lục giác (Hex Bar) cho phép nâng tạ ở tư thế trung lập, giảm căng thẳng lên lưng dưới khi thực hiện Deadlift.",
    },
    {
      name: "tire",
      description:
        "Lốp xe lớn dùng trong các bài tập chức năng như lật lốp (Tire Flip) và đập búa (Sledgehammer).",
    },
    {
      name: "stationary bike",
      description:
        "Xe đạp tập cố định, lý tưởng cho việc khởi động, hạ nhiệt và tập luyện tim mạch cường độ thấp.",
    },
    {
      name: "wheel roller",
      description:
        "Con lăn tập bụng, giúp tăng cường sức mạnh cơ lõi (core) và cơ bụng.",
    },
    {
      name: "smith machine",
      description:
        "Máy Smith có thanh tạ cố định di chuyển theo phương thẳng đứng, cung cấp sự ổn định tối đa.",
    },
    {
      name: "hammer",
      description:
        "Búa tạ (Sledgehammer) dùng để đập vào lốp xe hoặc các vật cản khác, tăng sức mạnh bùng nổ và sức bền.",
    },
    {
      name: "skierg machine",
      description:
        "Máy tập mô phỏng động tác trượt tuyết, cung cấp bài tập toàn thân, đặc biệt là cơ lưng, vai và tay.",
    },
    {
      name: "roller",
      description:
        "Con lăn xoa bóp (Foam Roller) dùng để tự mát-xa và giải phóng cơ (Self-Myofascial Release).",
    },
    {
      name: "resistance band",
      description:
        "Dây kháng lực, cung cấp sức cản thay đổi, dùng cho phục hồi chức năng hoặc tăng cường độ cho bài tập cơ bắp.",
    },
    {
      name: "bosu ball",
      description:
        "Bán cầu thăng bằng (Bosu Ball) dùng để tăng cường sự ổn định, thăng bằng và sức mạnh cơ lõi.",
    },
    {
      name: "weighted",
      description:
        "Thiết bị có trọng lượng được đeo thêm (như áo vest tạ) để tăng độ khó cho các bài tập thể hình hoặc sức bền.",
    },
    {
      name: "olympic barbell",
      description:
        "Thanh tạ chuẩn Olympic (20kg) được sử dụng trong các bài tập nâng tạ cơ bản như Squat, Bench Press, Overhead Press.",
    },
    {
      name: "kettlebell",
      description:
        "Tạ chuông, dùng cho các bài tập chức năng, bùng nổ và toàn thân như Swing, Snatch, Get-up.",
    },
    {
      name: "upper body ergometer",
      description:
        "Máy tập tim mạch chỉ dùng phần thân trên, tốt cho những người bị chấn thương chân hoặc muốn tập trung vào phần thân trên.",
    },
    {
      name: "sled machine",
      description:
        "Thiết bị đẩy hoặc kéo tạ trên mặt đất (Prowler Sled), lý tưởng cho tập luyện sức bền và sức mạnh chân.",
    },
    {
      name: "ez barbell",
      description:
        "Thanh tạ EZ có đường cong giúp giảm căng thẳng lên cổ tay khi tập Biceps Curl hoặc Triceps Extension.",
    },
    {
      name: "dumbbell",
      description:
        "Tạ đơn, dùng cho các bài tập cần sự linh hoạt và phạm vi chuyển động lớn, giúp cải thiện sự mất cân bằng giữa hai bên cơ thể.",
    },
    {
      name: "rope",
      description:
        "Dây thừng tập lực (Battle Rope) hoặc dây kéo dùng cho các bài tập sức bền, tim mạch và sức mạnh bùng nổ.",
    },
    {
      name: "barbell",
      description:
        "Thanh tạ thẳng, thiết bị cơ bản và phổ biến nhất trong các bài tập sức mạnh tổng hợp.",
    },
    {
      name: "band",
      description:
        "Dây tập kháng lực (Resistance Band) loại nhỏ, thường dùng để tăng kích hoạt cơ mông (Glute Activation).",
    },
    {
      name: "stability ball",
      description:
        "Bóng tập thăng bằng (Swiss Ball) dùng để tăng cường cơ lõi và độ ổn định trong nhiều bài tập.",
    },
    {
      name: "medicine ball",
      description:
        "Bóng tạ, dùng cho các bài tập tốc độ, sức mạnh bùng nổ và xoay thân.",
    },
    {
      name: "assisted",
      description:
        "Các máy hoặc dây hỗ trợ làm giảm trọng lượng cơ thể (ví dụ: Assisted Pull-up Machine).",
    },
    {
      name: "leverage machine",
      description:
        "Máy tập sử dụng cơ chế đòn bẩy (Leverage) để tạo ra lực cản, mang lại cảm giác nâng tạ tự do nhưng ổn định hơn.",
    },
    {
      name: "cable",
      description:
        "Hệ thống dây cáp và ròng rọc, cung cấp lực căng liên tục ở mọi góc độ trong suốt phạm vi chuyển động.",
    },
    {
      name: "body weight",
      description:
        "Sử dụng trọng lượng cơ thể của chính người tập để tạo ra lực cản (ví dụ: Push-up, Squat).",
    },
  ];

  // 3. Chuẩn hóa tên (In hoa chữ cái đầu)
  const equipmentsData: Partial<IEquipment>[] = rawEquipmentsData.map(
    (item) => ({
      ...item,
      // Áp dụng hàm toTitleCase() cho trường name
      name: toTitleCase(item.name),
    })
  );

  // 4. Chèn (Insert) dữ liệu vào cơ sở dữ liệu
  const docs = await Equipment.insertMany(equipmentsData);
  console.log(`✅ Seeded ${docs.length} Equipments`);
  return docs;
}
