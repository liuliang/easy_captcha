module EasyCaptcha
  # captcha controller
  class CaptchaController < ActionController::Base
    before_filter :overwrite_cache_control
    # captcha action send the generated image to browser
    def captcha
      if params[:format] == "wav" and EasyCaptcha.espeak?
        data = generate_speech_captcha
        t = 'audio/wav'
      else
        data = generate_captcha
        t = 'image/png'
      end
      $redis.setex("captcha:#{params[:k]}", 3.minutes.to_i, session[:captcha]) if params[:k].present?
      send_data data, :disposition => 'inline', :type => t
    end

    private
    # Overwrite cache control for Samsung Galaxy S3 (remove no-store)
    def overwrite_cache_control
      response.headers["Cache-Control"] = "no-cache, max-age=0, must-revalidate"
      response.headers["Pragma"] = "no-cache"
      response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
    end
  end
end
