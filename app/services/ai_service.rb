require "net/http"
require "uri"
require "json"

class AiService
  GROQ_URL = "https://api.groq.com/openai/v1/chat/completions"
  MODEL = "llama-3.3-70b-versatile"
  MAX_RETRIES = 3

  def initialize(api_key = ENV["GROQ_API_KEY"])
    @api_key = api_key
  end

  def chat(prompt)
    if @api_key.blank?
      Rails.logger.error "AI Service Error: GROQ_API_KEY is not set!"
      return "ขอโทษด้วยครับ ยังไม่ได้ตั้งค่า API Key สำหรับระบบ AI 🔑"
    end

    uri = URI(GROQ_URL)
    retries = 0

    loop do
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 30
      http.open_timeout = 10

      request = Net::HTTP::Post.new(uri)
      request["Content-Type"] = "application/json"
      request["Authorization"] = "Bearer #{@api_key}"
      request.body = {
        model: MODEL,
        messages: [
          { role: "system", content: "คุณเป็นผู้ช่วย AI ที่ตอบเป็นภาษาไทย กระชับ เข้าใจง่าย เป็นกันเอง" },
          { role: "user", content: prompt }
        ],
        max_tokens: 1024,
        temperature: 0.7
      }.to_json

      response = http.request(request)

      # Handle rate limiting with retry
      if response.code == "429" && retries < MAX_RETRIES
        retries += 1
        wait_time = 2 ** retries
        Rails.logger.warn "AI Service rate limited (429). Retry #{retries}/#{MAX_RETRIES} after #{wait_time}s"
        sleep(wait_time)
        next
      end

      unless response.code == "200"
        Rails.logger.error "AI Service HTTP #{response.code}: #{response.body.truncate(500)}"
        return "ขอโทษด้วยครับ ระบบ AI มีปัญหาชั่วคราว (#{response.code}) กรุณาลองใหม่อีกครั้ง 🙏"
      end

      parsed = JSON.parse(response.body)
      result = parsed.dig("choices", 0, "message", "content")
      return result.presence || "ขอโทษด้วยครับ ระบบ AI ไม่สามารถสร้างคำตอบได้ กรุณาลองใหม่อีกครั้ง 🙏"
    end
  rescue Net::ReadTimeout, Net::OpenTimeout => e
    Rails.logger.error "AI Service Timeout: #{e.message}"
    "ขอโทษด้วยครับ ระบบ AI ตอบช้าเกินไป กรุณาลองใหม่อีกครั้ง ⏳"
  rescue StandardError => e
    Rails.logger.error "AI Service Error: #{e.class} - #{e.message}"
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
