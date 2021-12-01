class Common

  def validateTokens(tokens, delimiters)
    if tokens.empty?
      raise "EMPTY TOKENS"
    end
    joined_tokens = tokens.join("+")
    # delimiters = [/(-)/, /(=)/]
    formatted = joined_tokens.split(Regexp.union(delimiters))
    return formatted.reject { |keyword| keyword == "" or keyword == "+" }
  end

end