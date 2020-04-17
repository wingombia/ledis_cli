class LedisController < ApplicationController
  def cli
  end

  def parse
    result = Parser.new(lines: [params[:command]]).perform
    render json: {
      result: result
    }
  end
end
