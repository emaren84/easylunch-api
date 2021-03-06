# Meal Meet Up model
class MealMeetUp < ActiveRecord::Base
  has_many :meal_meet_up_logs
  has_many :meal_meet_up_tasks
  belongs_to :admin, class_name: 'User', foreign_key: 'admin_id'
  belongs_to :messenger, class_name: 'CodeTable', foreign_key: 'messenger_code'
  belongs_to :status,    class_name: 'CodeTable', foreign_key: 'meetup_status'

  # 빈 MeetUp 생성
  def self.init_meetup(params)
    create(messenger_code: CodeTable.find_messenger(params[:messenger]).id,
           messenger_room_id: params[:messenger_room_id],
           meetup_status: CodeTable.find_meetup_status('created').id)
  end

  def update_status(total_price, meetup_status, pay_type)
    pay_avg(total_price.to_i) if pay_type == 'n'
    update(total_price: total_price.to_i,
           meetup_status: CodeTable.find_meetup_status(meetup_status).id,
           pay_type: pay_type)
  end

  def pay_avg(total_price)
    avg_price = total_price / meal_meet_up_tasks.count
    meal_meet_up_tasks.each do |task|
      task.meal_log.update(price: avg_price)
    end
  end

  # 사용자가 입력한 가격이 기존의 합계를 초과하는지 확인
  def price_overcharged?(params)
    user = User.find_by(service_uid: params[:member_id])
    user_before_price = user.find_enrolled_meetup(id).price.to_i
    price = params[:price].to_i

    sum = price_sum

    total_price < sum - user_before_price + price
  end

  # 해당 MeetUp에 속한 모든 맴버들의 현재 지불가격 합계
  def price_sum
    meal_meet_up_tasks.joins(:meal_log).inject(0) do |total, task|
      total + task.meal_log.price.to_i
    end
  end

  # 해당 meetup과 관련된 모든 맴버들의 정보를 배열로 리턴
  def members_info
    meal_meet_up_tasks.map do |task|
      log = task.meal_log
      { member_uid: log.user.service_uid,
        menu: log.menu_name,
        price: log.price,
        status: task.status.value }
    end
  end
end
