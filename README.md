# 🎣 그물 (Geu-mul)

> **그** 때의 **물**고기...  
> 매일같이 출조出釣 나가는 당신만의 물고기 도감 🐟🐠🐡🫧

---

## 👨‍💻 팀 소개

| 이름 | 역할        | GitHub | 기타 |
|------|-------------|--------|------|
| 손재민 | Front-End     | -      | -    |
| 이국건 | Infra / Front | -      | -    |
| 이수정 | Front / Back  | -      | -    |
| 정주하 | AI            | -      | -    |
| 조윤장 | AI / Data     | -      | -    |
| 황치운 | AI / Back     | -      | -    |

---

## 🛠️ 기술 스택

### 🎨 Front-End
![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Figma](https://img.shields.io/badge/Figma-F24E1E?style=for-the-badge&logo=figma&logoColor=white)
![KakaoTalk](https://img.shields.io/badge/KakaoTalk-ffcd00?style=for-the-badge&logo=kakaotalk&logoColor=000000)
![Google](https://img.shields.io/badge/Google-4285F4?style=for-the-badge&logo=google&logoColor=white)
![Adobe](https://img.shields.io/badge/Adobe-FF0000?style=for-the-badge&logo=adobe&logoColor=white)
![Android Studio](https://img.shields.io/badge/Android%20Studio-346ac1?style=for-the-badge&logo=android-studio&logoColor=white)

### 🧩 Back-End & DB
![Java](https://img.shields.io/badge/Java-ED8B00?style=for-the-badge&logo=openjdk&logoColor=white)
![Spring Boot](https://img.shields.io/badge/SpringBoot-6DB33F?style=for-the-badge&logo=spring-boot&logoColor=white)
![Apache Tomcat](https://img.shields.io/badge/Tomcat-F8DC75?style=for-the-badge&logo=apache-tomcat&logoColor=black)
![MySQL](https://img.shields.io/badge/MySQL-005C84?style=for-the-badge&logo=mysql&logoColor=white)
![Redis](https://img.shields.io/badge/Redis-DD0031?style=for-the-badge&logo=redis&logoColor=white)
![Swagger](https://img.shields.io/badge/Swagger-85EA2D?style=for-the-badge&logo=swagger&logoColor=black)
![IntelliJ IDEA](https://img.shields.io/badge/IntelliJIDEA-000000?style=for-the-badge&logo=intellij-idea&logoColor=white)

### 🤖 AI
![Python](https://img.shields.io/badge/Python-FFD43B?style=for-the-badge&logo=python&logoColor=blue)
![Jupyter](https://img.shields.io/badge/Jupyter-FA0F00?style=for-the-badge&logo=jupyter&logoColor=white)
![Anaconda](https://img.shields.io/badge/Anaconda-44A833?style=for-the-badge&logo=anaconda&logoColor=white)
![TensorFlow](https://img.shields.io/badge/TensorFlow-FF6F00?style=for-the-badge&logo=TensorFlow&logoColor=white)
![PyTorch](https://img.shields.io/badge/PyTorch-EE4C2C?style=for-the-badge&logo=PyTorch&logoColor=white)
![NumPy](https://img.shields.io/badge/NumPy-013243?style=for-the-badge&logo=numpy&logoColor=white)
![Matplotlib](https://img.shields.io/badge/Matplotlib-ffffff?style=for-the-badge&logo=Matplotlib&logoColor=black)
![Keras](https://img.shields.io/badge/Keras-D00000?style=for-the-badge&logo=Keras&logoColor=white)
![ChatGPT](https://img.shields.io/badge/ChatGPT-74aa9c?style=for-the-badge&logo=openai&logoColor=white)

### ☁️ Infra
![Jenkins](https://img.shields.io/badge/Jenkins-D24939?style=for-the-badge&logo=Jenkins&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2CA5E0?style=for-the-badge&logo=docker&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-FF9900?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Samsung](https://img.shields.io/badge/Samsung-1428A0?style=for-the-badge&logo=samsung&logoColor=white)

### 🤝 협업 도구
![Notion](https://img.shields.io/badge/Notion-000000?style=for-the-badge&logo=notion&logoColor=white)
![Jira](https://img.shields.io/badge/Jira-0A0FFF?style=for-the-badge&logo=jira&logoColor=white)
![GitLab](https://img.shields.io/badge/GitLab-171717?style=for-the-badge&logo=gitlab&logoColor=white)
![Google Drive](https://img.shields.io/badge/Google%20Drive-4285F4?style=for-the-badge&logo=googledrive&logoColor=white)

---

## 🐟 주요 기능

### 🐳 메인화면 (어항)
![어항 영상](/docs/asset/어항영상.gif)  
- 내가 잡은 물고기를 어항에 추가할 수 있음  
- 동적인 물고기 움직임 구현  

---

### 📖 물고기 도감
![도감](/docs/asset/도감.gif) ![도감 이미지](/docs/asset/도감.png)  
- 수집한 물고기 정보 저장 (어종, 사진, 크기, 환경 등)  
- 도감 형태로 확인  

---

### 🎣 물고기 분류 및 길이 측정

#### 🔍 분류
- **ResNet50** 기반, 26종 어종 분류  
- **데이터 증강** 및 **94% 정확도 달성**

#### 📏 길이 측정
- **AR 기반 가늠자 없는 측정 기술**  
- **Yolov8 Instance Segmentation**으로 윤곽 검출  
- 실측 거리 계산  
- OnDevice → **QAT**, **TFLite 변환**

📸 데이터셋 예시:
![라벨링](/docs/asset/data_label.png)
![마스크](/docs/asset/mask.png)
![마스크2](/docs/asset/mask2.png)

📐 측정 방식:
![픽셀 측정](/docs/asset/길이측정픽셀.png)
![측정 수식](/docs/asset/수식.png)

---

### 🗺️ 낚시 포인트 정보 제공
![포인트 영상](/docs/asset/낚시포인트.gif)
![환경정보](/docs/asset/낚시포인트환경.png)

- 포인트별 물때, 날씨, 수온, 출몰 어종 제공  
- 포인트 저장 및 공유 기능

---

### 🤖 챗봇
![챗봇](/docs/asset/챗봇.gif)  
- OpenAI 기반 챗봇  
- 낚시 컨셉 맞춤형 프롬프트 적용  

---

### 💎 부가 기능
- 방문자 수, 좋아요 수, 수족관 가치 등 시각화  
- 방명록 및 랭킹 시스템 제공

---

## 📱 앱 디자인 컨셉

- 흑백 & 포인트 컬러 조합  
![컨셉 이미지](/docs/asset/app_concept.png)
![컬러 팔레트](/docs/asset/color.png)

---

## 📘 개발 문서

- 💫 [UI Draft (Figma)](https://www.figma.com/design/aFHv2WqsWfpDcSpTyc6GST/-%ED%8A%B9%ED%99%94-%ED%94%BC%EA%B7%B8%EB%A7%88-%EB%94%94%EC%9E%90%EC%9D%B8?node-id=0-1&p=f&t=fr7VlhcHYSwxK9Qv-0)  
- 🧠 [Sequence Diagram & 아이디어 보드](https://www.figma.com/board/gpobQfMnjRWzcn9z3rZtBo/-%ED%8A%B9%ED%99%94-%ED%98%91%EC%97%85%EB%B3%B4%EB%93%9C?node-id=0-1&p=f&t=7M8H351F2Qwb2Ra1-0)  
- 💾 ERD  
  ![ERD](/docs/asset/erd.png)

---

## 🎥 관련 영상

📺 [그물 앱 UCC](https://www.youtube.com/watch?v=zMpmVm-oTsA)

---

