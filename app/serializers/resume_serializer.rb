class ResumeSerializer
  def initialize(resume)
    @resume = resume
  end

  def as_json(*)
    {
      id: @resume.id,
      title: @resume.title,
      status: @resume.status,
      template_id: @resume.template_id,
      content: @resume.content,
      created_at: @resume.created_at,
      updated_at: @resume.updated_at
    }
  end
end
