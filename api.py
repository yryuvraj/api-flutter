from PyPDF2 import PdfReader
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.metrics.pairwise import cosine_similarity

def calculate_similarity(resume, job_description):
    text = [resume, job_description]
    cv = CountVectorizer()
    count_matrix = cv.fit_transform(text)
    similarity_score = cosine_similarity(count_matrix)[0][1]
    match_percentage = round(similarity_score * 100, 2)
    return match_percentage

def main():
    try:
        resume_path = 'abc.pdf'
        jd_path = 'xyz.pdf'

        with open(resume_path, 'rb') as resume_file, open(jd_path, 'rb') as jd_file:
            resume_reader = PdfReader(resume_file)
            resume_text = resume_reader.pages[0].extract_text()

            jd_reader = PdfReader(jd_file)
            jd_text = jd_reader.pages[0].extract_text()

            match_percentage = calculate_similarity(resume_text, jd_text)

            print(f'Match Percentage: {match_percentage}%')

    except Exception as e:
        print(f'Error: {str(e)}')

if __name__ == "__main__":
    main()
