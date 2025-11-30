# Hướng dẫn Triển khai Hệ thống LOD & GraphDB

Tài liệu này hướng dẫn từng bước để tích hợp GraphDB vào hệ thống OmniMer Health, chuyển đổi dữ liệu sang RDF và lưu trữ vào GraphDB.

## Bước 1: Cài đặt GraphDB với Docker

Chúng ta sẽ sử dụng **Ontotext GraphDB Free Edition**.

1.  Mở file `docker-compose.yml` ở thư mục gốc.
2.  Thêm service `graphdb` vào dưới `ai_service`:

```yaml
# 3. 🕸️ GraphDB (Knowledge Graph)
graphdb:
  image: ontotext/graphdb:10.6.3
  container_name: omnimer_health_graphdb
  ports:
    - "7200:7200"
  environment:
    - GDB_HEAP_SIZE=2G
  networks:
    - omnimer_network
  volumes:
    - ./graphdb_data:/opt/graphdb/home
```

3.  Chạy lại Docker:
    ```bash
    docker-compose up -d
    ```
4.  Truy cập `http://localhost:7200` để vào giao diện quản trị GraphDB.
5.  **Tạo Repository mới:**
    - Vào **Setup** -> **Repositories** -> **Create new repository**.
    - Chọn **GraphDB Free**.
    - Repository ID: `omnimer_health_lod`.
    - Giữ nguyên các cài đặt mặc định và nhấn **Create**.

## Bước 2: Cài đặt Thư viện hỗ trợ RDF

Trong thư mục `omnimer_health_server`, cài đặt thư viện `n3` để tạo chuỗi RDF (Turtle) dễ dàng hơn.

```bash
cd omnimer_health_server
npm install n3
npm install --save-dev @types/n3
```

## Bước 3: Cấu hình Biến môi trường

Thêm vào file `omnimer_health_server/.env`:

```properties
# GraphDB Configuration
GRAPHDB_URL=http://omnimer_health_graphdb:7200
GRAPHDB_REPO=omnimer_health_lod
```

## Bước 4: Tạo Service kết nối GraphDB

Tạo file mới: `src/domain/services/LOD/GraphDB.service.ts`

```typescript
import axios from "axios";
import { Writer } from "n3";

export class GraphDBService {
  private readonly baseUrl: string;
  private readonly repoName: string;

  constructor(baseUrl: string, repoName: string) {
    this.baseUrl = baseUrl;
    this.repoName = repoName;
  }

  // Hàm gửi SPARQL UPDATE để lưu dữ liệu
  async insertData(turtleData: string): Promise<void> {
    const sparqlUpdate = `
      INSERT DATA {
        ${turtleData}
      }
    `;

    try {
      await axios.post(
        `${this.baseUrl}/repositories/${this.repoName}/statements`,
        sparqlUpdate,
        {
          headers: {
            "Content-Type": "application/sparql-update",
          },
        }
      );
      console.log("✅ Data pushed to GraphDB successfully");
    } catch (error) {
      console.error("❌ Failed to push to GraphDB:", error);
    }
  }
}
```

## Bước 5: Tạo Mapper chuyển đổi dữ liệu (Data Transformation)

Tạo file: `src/domain/services/LOD/LODMapper.ts`

File này sẽ chứa các hàm nhận vào Model (User, Workout...) và trả về chuỗi RDF (Turtle) dựa trên thiết kế trong `health_data_lod_design.md`.

```typescript
import { Writer } from "n3";
import { IUser } from "../../models/Profile/User.model";
import { IWorkout } from "../../models/Workout/Workout.model";

const PREFIXES = {
  ":": "http://omnimer.health/data/",
  ont: "http://omnimer.health/ontology/",
  xsd: "http://www.w3.org/2001/XMLSchema#",
  schema: "http://schema.org/",
  sosa: "http://www.w3.org/ns/sosa/",
  // ... thêm các prefix khác từ file design
};

export class LODMapper {
  static mapUserToRDF(user: IUser): string {
    if (!user.isDataSharingAccepted) return "";

    const writer = new Writer({ prefixes: PREFIXES });
    const subject = `:${user._id.toString()}`; // Nên hash ID này để ẩn danh thực sự

    writer.addQuad(
      writer.namedNode(subject),
      writer.namedNode("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"),
      writer.namedNode("schema:Person")
    );

    // Thêm Gender
    if (user.gender) {
      writer.addQuad(
        writer.namedNode(subject),
        writer.namedNode("schema:gender"),
        writer.literal(user.gender)
      );
    }

    // Thêm Year of Birth
    if (user.birthday) {
      const year = user.birthday.getFullYear().toString();
      writer.addQuad(
        writer.namedNode(subject),
        writer.namedNode("schema:birthDate"),
        writer.literal(year, writer.namedNode("xsd:gYear"))
      );
    }

    let rdfOutput = "";
    writer.end((error, result) => (rdfOutput = result));
    return rdfOutput;
  }

  // Tương tự cho mapWorkoutToRDF, mapWatchLogToRDF...
}
```

## Bước 6: Tích hợp vào Quy trình nghiệp vụ

Bạn cần gọi `GraphDBService` sau khi lưu dữ liệu thành công vào MongoDB.

Ví dụ trong `Workout.controller.ts`:

```typescript
// ... sau khi workoutService.createWorkout thành công
const workout = await this.workoutService.createWorkout(data);

// Kiểm tra xem user có đồng ý chia sẻ không
const user = await this.userService.getUserById(userId);
if (user && user.isDataSharingAccepted) {
  // Chuyển đổi và đẩy sang GraphDB (chạy async không cần await để không chặn response)
  const rdfData = LODMapper.mapWorkoutToRDF(workout);
  this.graphDBService.insertData(rdfData);
}
```

## Bước 7: Kiểm tra kết quả

1.  Thực hiện một bài tập trên Mobile App.
2.  Kiểm tra log server xem có dòng "✅ Data pushed to GraphDB successfully" không.
3.  Vào GraphDB (`http://localhost:7200`), mục **SPARQL**, chạy query:

```sparql
PREFIX : <http://omnimer.health/data/>
PREFIX schema: <http://schema.org/>

SELECT ?s ?p ?o
WHERE {
    ?s a schema:ExerciseAction ;
       ?p ?o .
}
```
