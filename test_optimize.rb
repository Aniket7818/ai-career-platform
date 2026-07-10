require './config/environment'
resume = Resume.last
puts AiOptimizationService.optimize(resume, 'ats_booster')
