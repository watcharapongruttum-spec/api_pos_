class Auth < ApplicationRecord




    def self.login(email, password)
        user = User.find_by(username: email)
        if user&.authenticate(password)
            return respon_to_json(user)
        else
            return nil
        end
    end



    def self.login_admin(email, password)
        user = User.find_by(username: email, role: 'admin')
        if user&.authenticate(password)
            return respon_to_json(user)
        else
            return nil
        end
    end







    def self.decode_token(token)
        decoded = JWT.decode(token, Rails.application.secrets.secret_key_base)[0]
        HashWithIndifferentAccess.new decoded
    rescue
        nil
    end




    def self.generate_token(user)
        payload = { 
            user_id: user.id,
            exp: 24.hours.from_now.to_i
        }
        JWT.encode(payload, Rails.application.secrets.secret_key_base)
    end


    def self.respon_to_json(user = {})
      {
        token: generate_token(user),
        user: {
            id: user.id,
            username: user.username,
            name: user.name,
            role: user.role
        }
      }
    end







end
