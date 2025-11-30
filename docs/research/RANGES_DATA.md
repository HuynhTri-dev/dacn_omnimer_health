# Data Mocking Strategy: WatchLog Schema (Updated)

Tài liệu này định nghĩa các phạm vi giá trị hợp lệ, các ràng buộc logic và các kịch bản dữ liệu mẫu cho collection `WatchLogs` (Phiên bản Comprehensive Health) trong MongoDB.

## 1. Tổng quan về các trường dữ liệu (Field Specifications)

### 1.1. Thông tin chung & Sinh hiệu (Vital Signs)

| Tên trường             | Đơn vị | Min | Max | Trung bình (Avg) | Ghi chú Logic                                    |
| :--------------------- | :----- | :-- | :-- | :--------------- | :----------------------------------------------- |
| `date`                 | Date   | N/A | N/A | N/A              | Quy về 00:00:00 nếu là Daily Log.                |
| `nameDevice`           | String | N/A | N/A | N/A              | Enum: `PixelWatch`, `GalaxyWatch`, `AppleWatch`. |
| `heartRateRest`        | bpm    | 40  | 100 | 60 - 75          | Thấp ở VĐV, cao khi stress/ốm.                   |
| `heartRateAvg`         | bpm    | 50  | 180 | 70 - 130         |                                                  |
| `heartRateMax`         | bpm    | 100 | 220 | 170 - 190        | Max ≈ 220 - Tuổi.                                |
| `heartRateVariability` | ms     | 10  | 150 | 40 - 80          | **HRV**: Cao = Tốt (Phục hồi), Thấp = Stress.    |
| `spo2Avg`              | %      | 85  | 100 | 95 - 99          | < 90 là nguy hiểm (Hypoxia).                     |
| `spo2Min`              | %      | 80  | 100 | 90 - 95          | Thường thấp nhất khi ngủ (ngưng thở).            |
| `respiratoryRate`      | brpm   | 8   | 25  | 12 - 20          | Nhịp thở/phút (thường đo khi ngủ).               |
| `skinTemperature`      | °C     | 30  | 37  | 32 - 34.5        | Nhiệt độ da thường thấp hơn thân nhiệt (37°C).   |
| `bloodPressureSys`     | mmHg   | 90  | 160 | 110 - 120        | Tâm thu (Số trên).                               |
| `bloodPressureDia`     | mmHg   | 60  | 100 | 70 - 80          | Tâm trương (Số dưới).                            |

### 1.2. Vận động (Activity & Mobility)

| Tên trường       | Đơn vị | Min   | Max    | Trung bình     | Ghi chú Logic                                 |
| :--------------- | :----- | :---- | :----- | :------------- | :-------------------------------------------- |
| `steps`          | bước   | 0     | 50,000 | 4,000 - 10,000 |                                               |
| `distance`       | mét    | 0     | 42,000 | 3,000 - 8,000  | **Lưu ý:** Schema dùng mét. ~0.76m/bước.      |
| `caloriesActive` | kcal   | 0     | 2,000  | 200 - 600      | Calo do vận động.                             |
| `caloriesBMR`    | kcal   | 1,000 | 2,500  | 1,400 - 1,800  | Calo duy trì sự sống (cố định theo cân nặng). |
| `caloriesTotal`  | kcal   | 1,000 | 5,000  | 1,800 - 2,500  | **Logic:** ≈ Active + BMR.                    |
| `activeMinutes`  | phút   | 0     | 300    | 30 - 60        |                                               |
| `floorsClimbed`  | tầng   | 0     | 100    | 3 - 10         | 1 tầng ≈ 3 mét độ cao.                        |
| `standHours`     | giờ    | 0     | 24     | 8 - 14         | Số giờ trong ngày có đứng dậy > 1 phút.       |

### 1.3. Giấc ngủ chi tiết (Sleep & Recovery)

| Tên trường      | Đơn vị | Min | Max | Trung bình | Ghi chú Logic                        |
| :-------------- | :----- | :-- | :-- | :--------- | :----------------------------------- |
| `sleepDuration` | giờ    | 0   | 12  | 6.0 - 8.5  | Tổng thời gian ngủ.                  |
| `sleepDeep`     | giờ    | 0   | 3   | 1.0 - 1.5  | Ngủ sâu (Phục hồi cơ). ~15-20% tổng. |
| `sleepREM`      | giờ    | 0   | 3   | 1.5 - 2.0  | Ngủ mơ (Phục hồi não). ~20-25% tổng. |
| `sleepLight`    | giờ    | 0   | 6   | 3.0 - 4.5  | Ngủ nông. ~50% tổng.                 |
| `sleepAwake`    | giờ    | 0   | 1   | 0.2 - 0.5  | Thời gian thức giấc giữa đêm.        |
| `sleepQuality`  | 0-100  | 0   | 100 | 60 - 85    | Điểm giấc ngủ.                       |
| `stressLevel`   | 0-100  | 0   | 100 | 25 - 50    |                                      |

### 1.4. Cardio & Body Composition

| Tên trường          | Đơn vị    | Min | Max | Trung bình | Ghi chú Logic                     |
| :------------------ | :-------- | :-- | :-- | :--------- | :-------------------------------- |
| `vo2max`            | ml/kg/min | 20  | 70  | 35 - 50    | Chỉ số sức bền.                   |
| `runningCadence`    | spm       | 120 | 200 | 150 - 170  | Bước chạy/phút (chỉ có khi chạy). |
| `bodyFatPercentage` | %         | 5   | 50  | 15 - 30    | Nam: 10-20%, Nữ: 20-30%.          |
| `bmi`               | score     | 15  | 40  | 18.5 - 25  |                                   |

---

## 2. Các quy tắc ràng buộc dữ liệu (Validation Rules)

1.  **Logic Tổng năng lượng (Energy Balance):**

    - `caloriesTotal` ≈ `caloriesBMR` + `caloriesActive`
    - Sai số cho phép: ±5% (do cách tính của từng hãng khác nhau).

2.  **Logic Cấu trúc giấc ngủ (Sleep Structure):**

    - `sleepDuration` ≈ `sleepDeep` + `sleepREM` + `sleepLight`
    - _Lưu ý:_ `sleepAwake` thường **không** tính vào Duration (tùy thiết bị), hoặc tính vào "Time in Bed".
    - Nếu `sleepDuration` < 4 giờ -> `sleepQuality` phải thấp (< 50).

3.  **Logic Huyết áp (Blood Pressure):**

    - `bloodPressureSystolic` luôn luôn > `bloodPressureDiastolic`.
    - Hiệu số (Pulse Pressure) thường từ 30 - 50 mmHg.

4.  **Logic Vận động (Pace & Cadence):**
    - Nếu `activeMinutes` > 0 nhưng `steps` = 0 -> Có thể là đạp xe hoặc bơi lội.
    - Nếu `runningCadenceAvg` > 0 thì phải có `distance` và `steps` tăng vọt.

---

## 3. Các kịch bản Mock Data (Scenarios)

### Kịch bản A: Người dùng Healthy & Active (Mục tiêu mẫu)

- **Device:** Pixel Watch 3
- **Activity:** 10,000 bước, Chạy bộ 30p.
- **Sleep:** 7.5 tiếng, Deep sleep tốt (1.5h).
- **Vitals:** HRV cao (60ms), SpO2 (98%).

### Kịch bản B: Người dùng Stress & Thiếu ngủ (Cảnh báo)

- **Device:** Galaxy Watch 6
- **Activity:** 3,000 bước (ít vận động).
- **Sleep:** 5 tiếng, Deep sleep thấp (0.5h).
- **Vitals:** HRV thấp (25ms), Nhịp tim nghỉ cao (85 bpm), Stress Level cao (75).

### Kịch bản C: Vận động viên chuyên nghiệp (Marathoner)

- **Device:** Garmin Fenix
- **Activity:** 25,000 bước, 20km.
- **Cardio:** VO2 Max cao (60), Nhịp tim nghỉ thấp (45 bpm).
- **Body:** Mỡ thấp (10%), Cơ cao.

---

## 4. Dữ liệu JSON Mẫu (Updated Payload)

Dưới đây là mẫu JSON đầy đủ khớp với Schema mới:

```json
{
  "_id": "64f1a2b3c9e77b0012a...",
  "userId": "64f1a2b3c9e77b0012b...",
  "date": "2025-10-30T00:00:00.000Z",
  "nameDevice": "PixelWatch",
  "sourceBundleId": "com.google.android.apps.fitness",

  // 1. Vital Signs
  "heartRateRest": 58,
  "heartRateAvg": 72,
  "heartRateMax": 165,
  "heartRateVariability": 65, // Tốt
  "spo2Avg": 98,
  "spo2Min": 94,
  "respiratoryRate": 16,
  "skinTemperature": 33.5,
  "bloodPressureSystolic": 115,
  "bloodPressureDiastolic": 75,

  // 2. Activity
  "steps": 10245,
  "distance": 7800, // mét
  "floorsClimbed": 12,
  "activeMinutes": 65,
  "standHours": 10,

  "caloriesActive": 550,
  "caloriesBMR": 1650,
  "caloriesTotal": 2200, // 550 + 1650

  // 3. Sleep (Đơn vị: giờ)
  "sleepDuration": 7.5,
  "sleepDeep": 1.5,
  "sleepREM": 1.8,
  "sleepLight": 4.2,
  "sleepAwake": 0.3, // Thức giấc 18 phút
  "sleepQuality": 85,
  "stressLevel": 32, // Thấp

  // 4. Cardio
  "vo2max": 48,
  "runningCadenceAvg": 165,
  "runningPowerAvg": 250,

  // 5. Body Comp
  "bodyFatPercentage": 18.5,
  "skeletalMuscleMass": 32.5,
  "bmi": 22.4,
  "bodyWaterMass": 40.0
}
```
