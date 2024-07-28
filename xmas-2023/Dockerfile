FROM gcr.io/armada-dc-04/safron:latest
COPY css/ /web/css/
COPY dist/ /web/dist/
COPY img/ /web/img/
COPY index.html /web/
CMD ["/safron", "-path=/web", "-log-format=json", "-port=8080"]
