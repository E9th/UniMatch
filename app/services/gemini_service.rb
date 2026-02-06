require "net/http"
require "uri"
require "json"

class GeminiService
  BASE_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"

  def initialize(api_key = ENV["GEMINI_API_KEY"])
    @api_key = api_key
  end

  def chat(prompt)
    uri = URI("#{BASE_URL}?key=#{@api_key}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 30

    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request.body = {
      contents: [{ parts: [{ text: prompt }] }]
    }.to_json

    response = http.request(request)
    parsed_response = JSON.parse(response.body)

    # ดึงข้อความตอบกลับ
    result = parsed_response.dig("candidates", 0, "content", "parts", 0, "text")
    result.presence || "ขอโทษด้วยครับ ระบบ AI มีปัญหาชั่วคราว 🙏"
  rescue StandardError => e
    Rails.logger.error "Gemini API Error: #{e.message}"
    "ขอโทษด้วยครับ ระบบ AI มีปัญหาชั่วคราว 🙏"
  end

  # สร้าง Icebreaker สำหรับคู่ Match
  def generate_icebreaker(current_user, match_user)
    prompt = <<~PROMPT
      คุณเป็นผู้ช่วย AI ของแอป UniMatch ซึ่งเป็นแอปจับคู่เพื่อนติว
      
      ข้อมูลผู้ใช้ปัจจุบัน:
      - ชื่อ: #{current_user.name}
      - คณะ: #{current_user.faculty}
      - วิชาที่ถนัด: #{current_user.strong_subject}
      - วิชาที่อ่อน: #{current_user.weak_subject}
      - สไตล์การเรียน: #{current_user.study_style}
      
      ข้อมูลเพื่อนที่ Match:
      - ชื่อ: #{match_user.name}
      - คณะ: #{match_user.faculty}
      - วิชาที่ถนัด: #{match_user.strong_subject}
      - วิชาที่อ่อน: #{match_user.weak_subject}
      - สไตล์การเรียน: #{match_user.study_style}
      
      ช่วยคิดคำทักทายที่เป็นกันเองและน่าสนใจ เพื่อเริ่มต้นบทสนทนากับเพื่อนติวคนนี้ 
      พร้อมแนะนำวิธีที่ทั้งสองคนจะช่วยกันเรียนได้ ตอบเป็นภาษาไทย สั้นๆ กระชับ 2-3 ประโยค
    PROMPT

    chat(prompt)
  end

  # AI Chat สำหรับถามคำถามเรื่องการเรียน
  def study_chat(user_message, user)
    prompt = <<~PROMPT
      คุณเป็นผู้ช่วยติวเตอร์ AI ของแอป UniMatch 
      คุณช่วยตอบคำถามเรื่องการเรียน ให้คำแนะนำ และช่วยอธิบายเนื้อหาวิชาต่างๆ
      
      ข้อมูลนักศึกษา:
      - ชื่อ: #{user&.name}
      - คณะ: #{user&.faculty}
      - วิชาที่ถนัด: #{user&.strong_subject}
      - วิชาที่อ่อน: #{user&.weak_subject}
      
      คำถาม/ข้อความจากนักศึกษา: #{user_message}
      
      ตอบเป็นภาษาไทย กระชับ เข้าใจง่าย ถ้าเป็นคำถามเรื่องเรียนให้อธิบายอย่างละเอียด
    PROMPT

    chat(prompt)
  end
end
