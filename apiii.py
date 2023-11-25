from flask import Flask, request, jsonify
from PyPDF2 import PdfReader
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.metrics.pairwise import cosine_similarity

app = Flask(__name__)

def calculate_similarity(resume, job_description):
    text = [resume, job_description]
    cv = CountVectorizer()
    count_matrix = cv.fit_transform(text)
    similarity_score = cosine_similarity(count_matrix)[0][1]
    match_percentage = round(similarity_score * 100, 2)
    return match_percentage

@app.route('/calculate_similarity', methods=['POST'])
def calculate_similarity_endpoint():
    try:
        # Assuming the PDFs are sent as files in the request
        resume_file = request.files['resume']
        jd_file = request.files['jd']

        resume_reader = PdfReader(resume_file)
        resume_text = resume_reader.pages[0].extract_text()

        jd_reader = PdfReader(jd_file)
        jd_text = jd_reader.pages[0].extract_text()

        match_percentage = calculate_similarity(resume_text, jd_text)

        print(f'Match Percentage: {match_percentage}%')

        response_data = {'match_percentage': match_percentage}
        return jsonify(response_data)

    except Exception as e:
        error_message = str(e)
        print(f'Error: {error_message}')
        return jsonify({'error': error_message}), 500

if __name__ == "__main__":
    app.run(debug=True)
