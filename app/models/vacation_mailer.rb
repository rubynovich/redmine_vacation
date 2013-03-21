class VacationMailer < Mailer
  unloadable

  if Rails::VERSION::MAJOR < 3
    def from_author(user_id, issue_ids, vacation_range_id, author_id=nil)
      user = User.find(user_id)
      set_language_if_valid user.language
      recipients user.mail
      author = author_id && User.find(author_id) || vacation.user
      vacation = VacationRange.find(vacation_range_id)
      subject l(:mail_subject_vacation_from_author,
        :user => author.name,
        :vacation_start => vacation.start_date.strftime("%d.%m.%Y"),
        :vacation_end => vacation.end_date.strftime("%d.%m.%Y"))
      body :user => author,
           :issues => Issue.find(issue_ids),
           :vacation => vacation
      render_multipart('from_author', body)
    end

    def from_assigned_to(user_id, issue_ids, vacation_range_id, assigned_to_id=nil)
      user = User.find(user_id)
      set_language_if_valid user.language
      recipients user.mail
      assigned_to = assigned_to_id && User.find(assigned_to_id) || vacation.user
      vacation = VacationRange.find(vacation_range_id)
      subject l(:mail_subject_vacation_from_assigned_to,
        :user => assigned_to.name,
        :vacation_start => vacation.start_date.strftime("%d.%m.%Y"),
        :vacation_end => vacation.end_date.strftime("%d.%m.%Y"))
      body :user => assigned_to,
           :issues => Issue.find(issue_ids),
           :vacation => vacation
      render_multipart('from_assigned_to', body)
    end

    def render_multipart(method_name, body)
      if Setting.plain_text_mail?
        content_type "text/plain"
        body render(:file => "#{method_name}.text.erb",
                    :body => body,
                    :layout => 'mailer.text.erb')
      else
        content_type "multipart/alternative"
        part :content_type => "text/plain",
             :body => render(:file => "#{method_name}.text.haml",
                             :body => body, :layout => 'mailer.text.erb')
        part :content_type => "text/html",
             :body => render_message("#{method_name}.html.haml", body)
      end
    end
  else
    def from_author(user_id, issue_ids, vacation_range_id, author_id=nil)
      user = User.find(user_id)
      set_language_if_valid user.language
      recipients = user.mail

      @vacation = VacationRange.find(vacation_range_id)
      @user = author_id && User.find(author_id) || @vacation.user
      @issues = Issue.find(issue_ids)

      subject = l(:mail_subject_vacation_from_author,
        :user => @user.name,
        :vacation_start => @vacation.start_date.strftime("%d.%m.%Y"),
        :vacation_end => @vacation.end_date.strftime("%d.%m.%Y"))

      mail(
        :to => recipients,
        :subject => subject
      )
    end

    def from_assigned_to(user_id, issue_ids, vacation_range_id, assigned_to_id=nil)
      user = User.find(user_id)
      set_language_if_valid user.language
      recipients = user.mail

      @vacation = VacationRange.find(vacation_range_id)
      @user = assigned_to_id && User.find(assigned_to_id) || @vacation.user
      @issues = Issue.find(issue_ids)

      subject = l(:mail_subject_vacation_from_assigned_to,
        :user => @user.name,
        :vacation_start => @vacation.start_date.strftime("%d.%m.%Y"),
        :vacation_end => @vacation.end_date.strftime("%d.%m.%Y"))

      mail(
        :to => recipients,
        :subject => subject
      )
    end
  end
end
