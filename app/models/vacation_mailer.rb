class VacationMailer < Mailer
  unloadable

  def from_author(user, issues, vacation, author=nil)
    set_language_if_valid user.language
    recipients user.mail
    author ||= vacation.user
    subject l(:mail_subject_vacation_from_author, 
      :user => author.name, 
      :vacation_start => vacation.start_date.strftime("%d.%m.%Y"), 
      :vacation_end => vacation.end_date.strftime("%d.%m.%Y"))
    body :user => author, 
         :issues => issues,
         :vacation => vacation
    render_multipart('from_author', body)
  end

  def from_assigned_to(user, issues, vacation, assigned_to=nil)
    set_language_if_valid user.language
    recipients user.mail
    assigned_to ||= vacation.user
    subject l(:mail_subject_vacation_from_assigned_to, 
      :user => assigned_to.name, 
      :vacation_start => vacation.start_date.strftime("%d.%m.%Y"), 
      :vacation_end => vacation.end_date.strftime("%d.%m.%Y"))
    body :user => assigned_to, 
         :issues => issues,
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
end
