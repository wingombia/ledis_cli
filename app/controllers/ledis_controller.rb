class LedisController < ApplicationController
  def cli
    if Ledis.storage.empty? && Ledis::LOG_FILE.exist?
      Ledis.load
    end
  end

  def parse
    result = Parser.new(lines: [params[:command]]).perform
    render json: {
      result: result
    }
  end
end
