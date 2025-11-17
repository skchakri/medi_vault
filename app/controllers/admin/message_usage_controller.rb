# frozen_string_literal: true

module Admin
  class MessageUsageController < AdminController
    def index
      # Date range filtering
      @start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : 30.days.ago.to_date
      @end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.today

      # Get all usage within date range
      @usage_records = MessageUsage.in_date_range(@start_date, @end_date)
                                    .includes(:user)
                                    .order(sent_at: :desc)
                                    .page(params[:page])
                                    .per(50)

      # Calculate statistics
      @stats = {
        total_messages: @usage_records.count,
        total_emails: @usage_records.email.count,
        total_sms: @usage_records.sms.count,
        total_cost: @usage_records.total_cost,
        sent_count: @usage_records.sent.count,
        failed_count: @usage_records.failed.count
      }

      # Per user breakdown
      @user_stats = MessageUsage.in_date_range(@start_date, @end_date)
                                .group(:user_id)
                                .select('user_id,
                                         COUNT(*) as message_count,
                                         SUM(CASE WHEN message_type = 0 THEN 1 ELSE 0 END) as email_count,
                                         SUM(CASE WHEN message_type = 1 THEN 1 ELSE 0 END) as sms_count,
                                         SUM(cost_cents) as total_cost_cents')
                                .includes(:user)
                                .order('message_count DESC')
                                .limit(20)

      # Daily breakdown for chart
      @daily_stats = MessageUsage.in_date_range(@start_date, @end_date)
                                  .group("DATE(sent_at)")
                                  .group(:message_type)
                                  .count

      respond_to do |format|
        format.html
        format.csv { send_data generate_csv, filename: "message-usage-#{@start_date}-to-#{@end_date}.csv" }
      end
    end

    private

    def generate_csv
      require 'csv'

      CSV.generate(headers: true) do |csv|
        csv << ['Date', 'User', 'Type', 'Status', 'Cost', 'Provider', 'Error']

        MessageUsage.in_date_range(@start_date, @end_date)
                    .includes(:user)
                    .order(sent_at: :desc)
                    .find_each do |usage|
          csv << [
            usage.sent_at&.strftime('%Y-%m-%d %H:%M'),
            usage.user.email,
            usage.message_type,
            usage.status,
            "$#{usage.cost_dollars}",
            usage.provider,
            usage.error_message
          ]
        end
      end
    end
  end
end
