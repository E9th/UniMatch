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
          { role: "system", content: "คุณเป็นเพื่อนติวในมหาวิทยาลัย ชื่อ \"น้องAI\" พูดไทยแบบวัยรุ่น เป็นกันเอง ใช้คำสั้นๆ ไม่เกิน 2-3 ประโยคต่อข้อความ ห้ามตอบยาว ห้ามใช้หัวข้อ ห้ามใช้ bullet point ถ้าเป็นคำถามเรื่องเรียนให้อธิบายง่ายๆ เหมือนเพื่อนสอนเพื่อน ใส่อีโมจิบ้างเล็กน้อย" },
          { role: "user", content: prompt }
        ],
        max_tokens: 256,
        temperature: 0.8
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
      ช่วยคิดคำทักทายสั้นๆ 1-2 ประโยค เป็นกันเอง เหมือนเพื่อนในมหาลัยทักกัน
      เราชื่อ#{current_user.name} (คณะ#{current_user.faculty} ถนัด#{current_user.strong_subject} อ่อน#{current_user.weak_subject})
      จะทักเพื่อนคณะ#{match_user.faculty} ที่ถนัด#{match_user.strong_subject}
      ให้มันดูเป็นธรรมชาติ ไม่เป็นทางการ ใส่อีโมจิได้นิดหน่อย
    PROMPT

    chat(prompt)
  end

  # AI Chat สำหรับถามคำถามเรื่องการเรียน
  def study_chat(user_message, user)
    prompt = <<~PROMPT
      เพื่อนชื่อ#{user&.name} คณะ#{user&.faculty} (ถนัด#{user&.strong_subject} อ่อน#{user&.weak_subject}) ส่งข้อความมาว่า:
      "#{user_message}"
      ตอบสั้นๆ เป็นกันเอง เหมือนเพื่อนคุยกัน ถ้าเป็นคำถามวิชาการให้อธิบายง่ายๆ พอเข้าใจ ไม่ต้องยาว
    PROMPT

    chat(prompt)
  end
end
